import SwiftUI
import Things4

import UniformTypeIdentifiers

struct ToDoListView: View {
    @EnvironmentObject var store: DatabaseStore
    var selection: ListSelection
    @State private var editMode: EditMode = .inactive
    @State private var multiSelection = Set<UUID>()
    @State private var showSchedulerFor: UUID?

    var body: some View {
        List(selection: $multiSelection) {
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
                let todos = store.filteredToDos(selection: selection)
                let noHeading = todos.filter { $0.headingID == nil }
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
                        ForEach(todos.filter { $0.headingID == heading.id }) { todo in
                            todoRow(todo)
                        }
                        .onDelete { offsets in
                            store.deleteTodo(at: offsets, selection: selection)
                        }
                    }
                }
            } else {
                ForEach(store.filteredToDos(selection: selection)) { todo in
                    todoRow(todo)
                }
                .onDelete { offsets in
                    store.deleteTodo(at: offsets, selection: selection)
                }
            }
        }
        .navigationTitle(selection.title(in: store.database))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { store.addTodo(to: selection) }) { Image(systemName: "plus") }
            }
            if case let .project(projectID) = selection {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { store.addHeading(to: projectID) }) { Image(systemName: "text.append") }
                }
            }
        }
        .environment(\.editMode, $editMode)
        .overlay(alignment: .bottomTrailing) {
            MagicPlusButton {
                store.addTodo(to: selection)
            }
        }
        .overlay(alignment: .leading) {
            if case let .project(projectID) = selection {
                Color.clear
                    .frame(width: 40)
                    .contentShape(Rectangle())
                    .onDrop(of: [.text], isTargeted: nil) { _ in
                        store.addHeading(to: projectID)
                        return true
                    }
            }
        }
        .sheet(item: $showSchedulerFor) { id in
            SchedulerView(todo: store.binding(for: id))
        }
    }

    @ViewBuilder
    private func todoRow(_ todo: ToDo) -> some View {
        NavigationLink(destination: ToDoDetailView(store: store, todo: store.binding(for: todo.id))) {
            HStack {
                Image(systemName: todo.status == .completed ? "checkmark.circle.fill" : "circle")
                    .onTapGesture { store.toggleCompletion(for: todo.id) }
                Text(todo.title)
                    .strikethrough(todo.status == .completed)
                    .foregroundColor(todo.status == .completed ? .gray : .primary)
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                showSchedulerFor = todo.id
            } label: {
                Label("When", systemImage: "calendar")
            }
        }
        .swipeActions(edge: .trailing) {
            Button {
                editMode = .active
                multiSelection.insert(todo.id)
            } label: {
                Label("Select", systemImage: "checkmark.circle")
            }
            .tint(.blue)
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
}
