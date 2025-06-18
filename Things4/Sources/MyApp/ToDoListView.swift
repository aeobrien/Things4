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
    var selection: ListSelection
    #if os(iOS)
    @State private var editMode: EditMode = .inactive
    #else
    @State private var isEditing = false
    #endif
    @State private var multiSelection = Set<UUID>()
    @State private var showSchedulerFor: SchedulerItem?
    @State private var showingTrash = false

    var body: some View {
        let todos: [ToDo] = {
            if case .list(.logbook) = selection, showingTrash {
                return store.database.toDos.filter { $0.status == .canceled }
            } else {
                return store.filteredToDos(selection: selection)
            }
        }()

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
                }
                .onDelete { offsets in
                    if case .list(.logbook) = selection, showingTrash {
                        let ids = offsets.map { todos[$0].id }
                        ids.forEach(store.deletePermanently)
                    } else {
                        store.deleteTodo(at: offsets, selection: selection)
                    }
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle(selection.title(in: store.database))
        #if os(macOS)
        .navigationSubtitle("\(todos.count) items")
        #endif
        .toolbar {
            if case .list(.logbook) = selection {
                ToolbarItemGroup(placement: .automatic) {
                    Picker("", selection: $showingTrash) {
                        Text("Logbook").tag(false)
                        Text("Trash").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                if showingTrash {
                    ToolbarItem(placement: .automatic) {
                        Button("Empty Trash") { store.emptyTrash() }
                    }
                }
            } else {
                ToolbarItem(placement: .automatic) {
                    Button(action: { store.addTodo(to: selection) }) { Image(systemName: "plus") }
                }
                if case let .project(projectID) = selection {
                    ToolbarItem(placement: .automatic) {
                        Button(action: { store.addHeading(to: projectID) }) { Image(systemName: "text.append") }
                    }
                }
            }
        }
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
        .task { await calendar.loadUpcomingEvents() }
        .task { await reminders.loadReminders() }
    }

    @ViewBuilder
    private func todoRow(_ todo: ToDo) -> some View {
        NavigationLink(destination: ToDoDetailView(todo: store.binding(for: todo.id))) {
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        store.toggleCompletion(for: todo.id)
                    }
                }) {
                    Image(systemName: todo.status == .completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.status == .completed ? .accentColor : .secondary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .strikethrough(todo.status == .completed)
                        .foregroundColor(todo.status == .completed ? .secondary : .primary)
                        .font(.system(size: 14))
                    
                    if !todo.tagIDs.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(todo.tagIDs, id: \.self) { tagID in
                                if let tag = store.database.tags.first(where: { $0.id == tagID }) {
                                    Text(tag.name)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                if let deadline = todo.deadline {
                    Text(deadline, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .swipeActions(edge: .leading) {
            Button {
                showSchedulerFor = SchedulerItem(id: todo.id)
            } label: {
                Label("When", systemImage: "calendar")
            }
        }
        .swipeActions(edge: .trailing) {
            if todo.status == .open {
                Button(role: .destructive) {
                    store.cancelTodo(todo.id)
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }
                Button {
                    #if os(iOS)
                    editMode = .active
                    #else
                    isEditing = true
                    #endif
                    multiSelection.insert(todo.id)
                } label: {
                    Label("Select", systemImage: "checkmark.circle")
                }
                .tint(.blue)
            } else if todo.status == .canceled {
                Button(role: .destructive) {
                    store.deletePermanently(todo.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    store.restoreTodo(todo.id)
                } label: {
                    Label("Restore", systemImage: "arrow.uturn.left")
                }
                .tint(.blue)
            } else {
                Button {
                    #if os(iOS)
                    editMode = .active
                    #else
                    isEditing = true
                    #endif
                    multiSelection.insert(todo.id)
                } label: {
                    Label("Select", systemImage: "checkmark.circle")
                }
                .tint(.blue)
            }
        }
        .onDrop(of: [.text], isTargeted: nil) { _ in
            store.insertTodo(after: todo.id, in: selection)
            return true
        }
    }
}

#Preview {
    ToDoListView(selection: .list(.inbox))
        .environmentObject(DatabaseStore())
        .environmentObject(CalendarManager.shared)
        .environmentObject(RemindersImporter.shared)
}

