import SwiftUI
import Things4

struct ToDoListView: View {
    @ObservedObject var store: DatabaseStore
    var selection: ListSelection

    var body: some View {
        List {
            ForEach(store.filteredToDos(selection: selection)) { todo in
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
            .onDelete { offsets in
                store.deleteTodo(at: offsets, selection: selection)
            }
        }
        .navigationTitle(selection.title(in: store.database))
        .toolbar { Button(action: { store.addTodo(to: selection) }) { Image(systemName: "plus") } }
    }
}

#Preview {
    ToDoListView(store: DatabaseStore(), selection: .list(.inbox))
}