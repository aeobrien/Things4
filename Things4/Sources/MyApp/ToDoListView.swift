import SwiftUI
import Things4

struct ToDoListView: View {
    @ObservedObject var store: DatabaseStore
    var selection: ListSelection

    var body: some View {
        List {
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
    }
}

#Preview {
    ToDoListView(store: DatabaseStore(), selection: .list(.inbox))
}
