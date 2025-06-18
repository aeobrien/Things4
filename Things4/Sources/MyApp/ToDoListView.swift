import SwiftUI
import Things4

import UniformTypeIdentifiers

struct SchedulerItem: Identifiable {
    let id: UUID
}

struct ToDoListView: View {
    @EnvironmentObject var store: DatabaseStore
    @EnvironmentObject var calendar: CalendarManager
    @EnvironmentObject var reminders: RemindersImporter
    @EnvironmentObject var selectionStore: SelectionStore
    var selection: ListSelection
    #if os(iOS)
    @State private var editMode: EditMode = .inactive
    #else
    @State private var isEditing = false
    #endif
    @State private var multiSelection = Set<UUID>()
    @State private var showSchedulerFor: SchedulerItem?
    @State private var expandedTodoID: UUID? = nil
    @State private var showingDeadlinePicker: UUID? = nil
    @State private var newTagName = ""
    @State private var showingQuickFind = false
    @State private var showingMoveMenu = false
    @State private var selectedTodos = Set<UUID>()
    @State private var showingRepeatModalFor: UUID? = nil
    @State private var showingTagPopoverFor: UUID? = nil
    @State private var showingInfoFor: UUID? = nil
    @State private var selectedFilterTags = Set<UUID>()
    @State private var recentlyCompletedTodos = Set<UUID>()
    @FocusState private var focusedField: UUID?
    @FocusState private var tagFieldFocused: Bool

    var body: some View {
        let allTodos = store.filteredToDos(selection: selection)
        // Include recently completed todos that are still showing
        let recentlyCompleted = store.database.toDos.filter { todo in
            recentlyCompletedTodos.contains(todo.id)
        }
        let todosWithRecent = allTodos + recentlyCompleted.filter { todo in
            !allTodos.contains(where: { $0.id == todo.id })
        }
        let todos: [ToDo] = {
            if selectedFilterTags.isEmpty {
                return todosWithRecent
            } else {
                return todosWithRecent.filter { todo in
                    !Set(todo.tagIDs).isDisjoint(with: selectedFilterTags)
                }
            }
        }()

        VStack(spacing: 0) {
            

            // ⟡ “25 new to-dos” banner
            if store.newItemsCount > 0 {
                HStack {
                    Text("You have \(store.newItemsCount) new to-dos")
                        .font(.footnote)
                        .fontWeight(.medium)
                    Spacer()
                    Button("OK") { store.clearNewItems() }
                        .font(.footnote.bold())
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.25))
                        .cornerRadius(4)
                }
                .padding()
                .background(Color.yellow.opacity(0.35))
                .cornerRadius(6)
                .padding(.horizontal)
            }

            
            // Tag filter bar
            if !store.database.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.database.tags.sorted(by: { $0.name < $1.name })) { tag in
                            Button(action: {
                                if selectedFilterTags.contains(tag.id) {
                                    selectedFilterTags.remove(tag.id)
                                } else {
                                    selectedFilterTags.insert(tag.id)
                                }
                            }) {
                                Text(tag.name)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(selectedFilterTags.contains(tag.id) ? Color.accentColor : Color.secondary.opacity(0.2))
                                    .foregroundColor(selectedFilterTags.contains(tag.id) ? .white : .primary)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        if !selectedFilterTags.isEmpty {
                            Divider()
                                .frame(height: 20)
                            
                            Button("Clear") {
                                selectedFilterTags.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
            }
            
            List(selection: $multiSelection) {
            if case .list(.inbox) = selection, !reminders.reminders.isEmpty {
                Section("Reminders") {
                    ForEach(reminders.reminders) { item in
                        Button(action: { Task { await reminders.importReminder(item.identifier, into: store) } }) {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text(item.title)
                            }
                        }
                    }
                }
            }

            if case .list(let list) = selection, (list == .today || list == .upcoming) {
                let events: [CalendarEvent] = {
                    let today = Calendar.current.startOfDay(for: Date())
                    if list == .today { return calendar.events(forDay: today) }
                    else { return calendar.upcomingEvents(after: today) }
                }()
                if !events.isEmpty {
                    Section("Events") {
                        ForEach(events) { event in
                            HStack {
                                Image(systemName: "calendar")
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                    Text(event.startDate, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            if case let .project(projectID) = selection {
                let progress = store.progress(for: projectID)
                Section {
                    HStack {
                        Text("Progress")
                        Spacer()
                        ProgressView(value: progress)
                            .progressViewStyle(.circular)
                    }
                }
                let headings = store.database.headings.filter { $0.parentProjectID == projectID }
                let projectTodos = todos
                let noHeading = projectTodos.filter { $0.headingID == nil }
                Section {
                    ForEach(noHeading) { todo in
                        todoRow(todo)
                    }
                    .onDelete { offsets in
                        store.deleteTodo(at: offsets, selection: selection)
                    }
                }
                ForEach(headings) { heading in
                    Section(header: TextField("Heading", text: store.bindingForHeading(heading.id).title)) {
                        ForEach(projectTodos.filter { $0.headingID == heading.id }) { todo in
                            todoRow(todo)
                        }
                        .onDelete { offsets in
                            store.deleteTodo(at: offsets, selection: selection)
                        }
                    }
                }
            } else {
                ForEach(todos) { todo in
                    todoRow(todo)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .onDelete { offsets in
                    if case .list(.trash) = selection {
                        let ids = offsets.map { todos[$0].id }
                        ids.forEach(store.deletePermanently)
                    } else {
                        store.deleteTodo(at: offsets, selection: selection)
                    }
                }
            }
            
            // Empty space at bottom to detect taps
            Section {
                Color.clear
                    .frame(height: 200)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        if expandedTodoID != nil {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                expandedTodoID = nil
                                focusedField = nil
                            }
                        }
                    }
            }
            }
            .listStyle(.plain)               // from .inset ➞ .plain
            .listRowSeparator(.hidden)
        .navigationTitle(selection.title(in: store.database))
        #if os(macOS)
        .navigationSubtitle("\(todos.count) items")
        #endif
        .toolbar {
            if case .list(.trash) = selection {
                ToolbarItem(placement: .automatic) {
                    Button("Empty Trash") { store.emptyTrash() }
                }
            }
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 24) {
                // New To-Do
                Button(action: { 
                    if case .list(.trash) = selection {
                        // Don't add to trash
                    } else {
                        store.addTodo(to: selection) 
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .disabled(selection == .list(.trash))
                .help("New To-Do")
                
                // New Heading (only for projects)
                if case let .project(projectID) = selection {
                    Button(action: { store.addHeading(to: projectID) }) {
                        Image(systemName: "rectangle.badge.plus")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .help("New Heading")
                }
                
                Divider()
                    .frame(height: 16)
                
                // When
                Button(action: { 
                    if let firstSelected = multiSelection.first {
                        showSchedulerFor = SchedulerItem(id: firstSelected)
                    }
                }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .disabled(multiSelection.isEmpty)
                .help("When")
                
                // Move
                Button(action: { showingMoveMenu = true }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .disabled(multiSelection.isEmpty)
                .help("Move")
                .popover(isPresented: $showingMoveMenu) {
                    MoveMenuView(selectedTodos: Array(multiSelection)) { destination in
                        // Move todos to destination
                        for todoID in multiSelection {
                            if let index = store.database.toDos.firstIndex(where: { $0.id == todoID }) {
                                switch destination {
                                case .list(let list):
                                    // Update todo properties based on list
                                    store.database.toDos[index].parentProjectID = nil
                                    store.database.toDos[index].parentAreaID = nil
                                    store.database.toDos[index].headingID = nil
                                    // Apply list-specific properties
                                    switch list {
                                    case .today:
                                        store.database.toDos[index].startDate = Date()
                                    case .someday:
                                        store.database.toDos[index].isSomeday = true
                                    default:
                                        break
                                    }
                                case .project(let projectID):
                                    store.database.toDos[index].parentProjectID = projectID
                                    store.database.toDos[index].parentAreaID = nil
                                    store.database.toDos[index].headingID = nil
                                case .area(let areaID):
                                    store.database.toDos[index].parentAreaID = areaID
                                    store.database.toDos[index].parentProjectID = nil
                                    store.database.toDos[index].headingID = nil
                                }
                            }
                        }
                        store.save()
                        multiSelection.removeAll()
                        showingMoveMenu = false
                    }
                }
                
                Spacer()
                
                // Quick Find
                Button(action: { showingQuickFind = true }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("Quick Find")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        #endif
        } // VStack
        #if os(iOS)
        .environment(\.editMode, $editMode)
        .overlay(alignment: .bottomTrailing) {
            MagicPlusButton {
                store.addTodo(to: selection)
            }
        }
        #endif
        .sheet(item: $showSchedulerFor) { item in
            SchedulerView(todo: store.binding(for: item.id))
        }
        .sheet(isPresented: $showingQuickFind) {
            QuickFindView()
                .environmentObject(store)
        }
        .sheet(item: Binding(
            get: { showingRepeatModalFor.flatMap { id in store.database.toDos.first { $0.id == id } } },
            set: { _ in showingRepeatModalFor = nil }
        )) { todo in
            RepeatModal(todo: store.binding(for: todo.id))
                .environmentObject(store)
        }
        .sheet(item: Binding(
            get: { showingInfoFor.flatMap { id in store.database.toDos.first { $0.id == id } } },
            set: { _ in showingInfoFor = nil }
        )) { todo in
            TodoInfoView(todo: todo)
        }
        .sheet(item: Binding(
            get: { showingTagPopoverFor.flatMap { id in store.database.toDos.first { $0.id == id } } },
            set: { _ in showingTagPopoverFor = nil }
        )) { todo in
            if let todoBinding = store.database.toDos.firstIndex(where: { $0.id == todo.id }) {
                TagSelectionPopover(todo: Binding(
                    get: { store.database.toDos[todoBinding] },
                    set: { store.database.toDos[todoBinding] = $0; store.save() }
                ))
                .environmentObject(store)
            }
        }
        .task { await calendar.loadUpcomingEvents() }
        .task { await reminders.loadReminders() }
    }

    @ViewBuilder
    private func todoRow(_ todo: ToDo) -> some View {
        let isExpanded = expandedTodoID == todo.id
        let binding = store.binding(for: todo.id)

        ToDoCardView(
            todo: binding,
            onExpand: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if expandedTodoID == todo.id {
                        expandedTodoID = nil
                        focusedField = nil
                    } else {
                        expandedTodoID = todo.id
                        focusedField = todo.id
                    }
                }
            },
            isExpanded: isExpanded,
            toggleComplete: {
                withAnimation(.easeOut(duration: 0.2)) {
                    store.toggleCompletion(for: todo.id)
                }
            }
        )
        .padding(.vertical, Theme.cardVSpacing)
        .listRowBackground(Color.clear)  // white cards on neutral backdrop
        .contextMenu { todoContextMenu(for: todo) }
    }
    
    private func addTag(to todoID: UUID) {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        store.addTag(trimmed, to: todoID)
        newTagName = ""
        tagFieldFocused = false
    }
    
    @ViewBuilder
    private func todoContextMenu(for todo: ToDo) -> some View {
        // When
        Button(action: { showSchedulerFor = SchedulerItem(id: todo.id) }) {
            Label("When", systemImage: "calendar")
        }
        
        // Move
        Menu {
            ForEach(DefaultList.allCases.filter { $0 != .trash && $0 != .logbook }) { list in
                Button(action: {
                    moveTodo(todo.id, to: .list(list))
                }) {
                    Label(list.title, systemImage: iconForList(list))
                }
            }
            
            Divider()
            
            ForEach(store.database.projects.filter { $0.status == .open }) { project in
                Button(action: {
                    moveTodo(todo.id, to: .project(project.id))
                }) {
                    Label(project.title, systemImage: "circle.fill")
                }
            }
            
            if !store.database.areas.isEmpty {
                Divider()
                
                ForEach(store.database.areas) { area in
                    Button(action: {
                        moveTodo(todo.id, to: .area(area.id))
                    }) {
                        Label(area.title, systemImage: "circle.fill")
                    }
                }
            }
        } label: {
            Label("Move", systemImage: "arrow.right")
        }
        
        // Tags
        Button(action: {
            showingTagPopoverFor = todo.id
        }) {
            Label("Tags", systemImage: "tag")
        }
        
        // Deadline
        Button(action: {
            showingDeadlinePicker = todo.id
        }) {
            Label("Deadline", systemImage: "flag")
        }
        
        // Complete
        Menu {
            Button(action: {
                store.toggleCompletion(for: todo.id)
            }) {
                Label("Mark as Completed", systemImage: "checkmark.circle")
            }
            
            Button(action: {
                store.cancelTodo(todo.id)
            }) {
                Label("Mark as Canceled", systemImage: "xmark.circle")
            }
        } label: {
            Label("Complete", systemImage: "checkmark")
        }
        
        // Shortcuts
        Menu {
            Menu {
                Button(action: {
                    updateTodoWhen(todo.id, startDate: nil, isSomeday: false)
                }) {
                    Text("Inbox")
                }
                
                Button(action: {
                    updateTodoWhen(todo.id, startDate: Date(), isSomeday: false)
                }) {
                    Text("Today")
                }
                
                Button(action: {
                    var evening = Date()
                    if let eveningTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: evening) {
                        evening = eveningTime
                    }
                    updateTodoWhen(todo.id, startDate: evening, isSomeday: false, isEvening: true)
                }) {
                    Text("This Evening")
                }
                
                Button(action: {
                    updateTodoWhen(todo.id, startDate: nil, isSomeday: true)
                }) {
                    Text("Someday")
                }
                
                Button(action: {
                    updateTodoWhen(todo.id, startDate: nil, isSomeday: false)
                }) {
                    Text("Clear")
                }
            } label: {
                Text("When")
            }
        } label: {
            Label("Shortcuts", systemImage: "star")
        }
        
        Divider()
        
        // Repeat
        Button(action: {
            showingRepeatModalFor = todo.id
        }) {
            Label("Repeat", systemImage: "repeat")
        }
        
        // Get Info
        Button(action: {
            showingInfoFor = todo.id
        }) {
            Label("Get Info", systemImage: "info.circle")
        }
        
        // Duplicate To-Do
        Button(action: {
            duplicateTodo(todo)
        }) {
            Label("Duplicate To-Do", systemImage: "doc.on.doc")
        }
        
        // Convert to Project
        Button(action: {
            convertToProject(todo)
        }) {
            Label("Convert to Project", systemImage: "folder.badge.plus")
        }
        
        // Delete To-Do
        Button(role: .destructive, action: {
            store.cancelTodo(todo.id)
        }) {
            Label("Delete To-Do", systemImage: "trash")
        }
        
        if todo.parentProjectID != nil {
            Divider()
            
            // Remove from Project
            Button(action: {
                removeFromProject(todo.id)
            }) {
                Label("Remove from Project", systemImage: "folder.badge.minus")
            }
        }
        
        if let projectID = todo.parentProjectID {
            Divider()
            
            // Show in Project
            Button(action: {
                selectionStore.selection = .project(projectID)
            }) {
                Label("Show in Project", systemImage: "arrow.right.circle")
            }
        }
        
        // Share
        Menu {
            // Copy Text
            Button(action: {
                copyTodoAsText(todo)
            }) {
                Label("Copy Text", systemImage: "doc.on.clipboard")
            }
            
            // Copy Link
            Button(action: {
                copyTodoLink(todo)
            }) {
                Label("Copy Link", systemImage: "link")
            }
            
            Divider()
            
            // Other share options would go here
            Text("Mail, Messages, Notes...")
                .foregroundColor(.secondary)
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        
        // Log Completed
        if todo.status == .completed {
            Button(action: {
                // Log completed action
            }) {
                Label("Log Completed", systemImage: "clock.arrow.circlepath")
            }
        }
        
        Divider()
        
        // Writing Tools (macOS Sequoia feature)
        #if os(macOS)
        if #available(macOS 15.0, *) {
            Menu {
                Button("Proofread") {}
                Button("Rewrite") {}
                Button("Make Friendly") {}
                Button("Make Professional") {}
                Button("Make Concise") {}
                Divider()
                Button("Summarize") {}
                Button("Create Key Points") {}
                Button("Make List") {}
                Button("Make Table") {}
            } label: {
                Label("Writing Tools", systemImage: "text.badge.star")
            }
            .disabled(true) // Enable when implementing
        }
        #endif
        
        // Services
        #if os(macOS)
        Menu {
            Text("Services...")
                .foregroundColor(.secondary)
        } label: {
            Label("Services", systemImage: "gearshape.2")
        }
        #endif
    }
    
    private func moveTodo(_ todoID: UUID, to destination: ListSelection) {
        guard let index = store.database.toDos.firstIndex(where: { $0.id == todoID }) else { return }
        
        switch destination {
        case .list(let list):
            store.database.toDos[index].parentProjectID = nil
            store.database.toDos[index].parentAreaID = nil
            store.database.toDos[index].headingID = nil
            
            switch list {
            case .today:
                store.database.toDos[index].startDate = Date()
                store.database.toDos[index].isSomeday = false
            case .someday:
                store.database.toDos[index].isSomeday = true
                store.database.toDos[index].startDate = nil
            default:
                store.database.toDos[index].isSomeday = false
                store.database.toDos[index].startDate = nil
            }
            
        case .project(let projectID):
            store.database.toDos[index].parentProjectID = projectID
            store.database.toDos[index].parentAreaID = nil
            store.database.toDos[index].headingID = nil
            
        case .area(let areaID):
            store.database.toDos[index].parentAreaID = areaID
            store.database.toDos[index].parentProjectID = nil
            store.database.toDos[index].headingID = nil
        }
        
        store.save()
    }
    
    private func updateTodoWhen(_ todoID: UUID, startDate: Date?, isSomeday: Bool, isEvening: Bool = false) {
        guard let index = store.database.toDos.firstIndex(where: { $0.id == todoID }) else { return }
        
        store.database.toDos[index].startDate = startDate
        store.database.toDos[index].isSomeday = isSomeday
        store.database.toDos[index].isEvening = isEvening
        
        store.save()
    }
    
    private func iconForList(_ list: DefaultList) -> String {
        switch list {
        case .inbox: return "tray"
        case .today: return "star"
        case .upcoming: return "calendar"
        case .anytime: return "tray.full"
        case .someday: return "archivebox"
        case .logbook: return "checkmark.circle"
        case .trash: return "trash"
        }
    }
    
    private func duplicateTodo(_ todo: ToDo) {
        var newTodo = todo
        newTodo.id = UUID()
        newTodo.creationDate = Date()
        newTodo.modificationDate = Date()
        newTodo.completionDate = nil
        newTodo.status = .open
        store.database.toDos.append(newTodo)
        store.save()
    }
    
    private func convertToProject(_ todo: ToDo) {
        let project = Project(
            title: todo.title,
            notes: todo.notes,
            startDate: todo.startDate,
            deadline: todo.deadline,
            tagIDs: todo.tagIDs,
            parentAreaID: todo.parentAreaID
        )
        store.database.projects.append(project)
        
        // Move any checklist items to todos in the project
        for item in todo.checklist {
            let newTodo = ToDo(
                title: item.title,
                parentProjectID: project.id
            )
            store.database.toDos.append(newTodo)
        }
        
        // Remove the original todo
        store.database.toDos.removeAll { $0.id == todo.id }
        store.save()
    }
    
    private func removeFromProject(_ todoID: UUID) {
        guard let index = store.database.toDos.firstIndex(where: { $0.id == todoID }) else { return }
        store.database.toDos[index].parentProjectID = nil
        store.database.toDos[index].headingID = nil
        store.save()
    }
    
    private func copyTodoAsText(_ todo: ToDo) {
        #if os(macOS)
        var text = todo.title
        if !todo.notes.isEmpty {
            text += "\n\n" + todo.notes
        }
        if !todo.tagIDs.isEmpty {
            let tagNames = todo.tagIDs.compactMap { tagID in
                store.database.tags.first { $0.id == tagID }?.name
            }
            text += "\n\nTags: " + tagNames.joined(separator: ", ")
        }
        if let deadline = todo.deadline {
            text += "\n\nDeadline: " + deadline.formatted()
        }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
    
    private func copyTodoLink(_ todo: ToDo) {
        #if os(macOS)
        let link = "things:///show?id=\(todo.id)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link, forType: .string)
        #endif
    }
}

#Preview {
    ToDoListView(selection: .list(.inbox))
        .environmentObject(DatabaseStore())
        .environmentObject(CalendarManager.shared)
        .environmentObject(RemindersImporter.shared)
        .environmentObject(SelectionStore())
}

