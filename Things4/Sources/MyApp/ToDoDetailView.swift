import SwiftUI
import Things4

struct ToDoDetailView: View {
    @ObservedObject var store: DatabaseStore
    @Binding var todo: ToDo
    @State private var newChecklistTitle = ""
    @State private var newTagName = ""

    var body: some View {
        Form {
            Section("Title") {
                TextField("Title", text: $todo.title)
                    .onChange(of: todo.title) { _ in store.save() }
            }
            Section("Notes") {
                TextEditor(text: $todo.notes)
                    .frame(minHeight: 150)
                    .onChange(of: todo.notes) { _ in store.save() }
            }
            Section("Checklist") {
                ForEach($todo.checklist) { $item in
                    HStack {
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                item.isCompleted.toggle()
                                store.save()
                            }
                        TextField("Item", text: $item.title)
                            .onChange(of: item.title) { _ in store.save() }
                    }
                }
                .onDelete { indexSet in
                    todo.checklist.remove(atOffsets: indexSet)
                    store.save()
                }
                HStack {
                    TextField("New item", text: $newChecklistTitle)
                    Button(action: addChecklistItem) { Image(systemName: "plus") }
                        .disabled(newChecklistTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            Section("Tags") {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(todo.tagIDs, id: \.self) { id in
                            if let tag = store.database.tags.first(where: { $0.id == id }) {
                                Text(tag.name)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                                    .onTapGesture { store.removeTag(id, from: todo.id) }
                            }
                        }
                    }
                }
                HStack {
                    TextField("New tag", text: $newTagName)
                    Button(action: addTag) { Image(systemName: "plus") }
                        .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            Section("When") {
                Toggle("Someday", isOn: Binding(get: {
                    todo.isSomeday
                }, set: { value in
                    todo.isSomeday = value
                    if value { todo.startDate = nil }
                    store.save()
                }))
                Toggle("Has Start Date", isOn: Binding(get: {
                    todo.startDate != nil
                }, set: { value in
                    if value {
                        todo.startDate = todo.startDate ?? Date()
                    } else {
                        todo.startDate = nil
                    }
                    store.save()
                }))
                if let _ = todo.startDate {
                    DatePicker("Start", selection: Binding(get: {
                        todo.startDate ?? Date()
                    }, set: { date in
                        todo.startDate = date
                        store.save()
                    }), displayedComponents: .date)
                }
            }
            Section("Deadline") {
                Toggle("Has Deadline", isOn: Binding(get: {
                    todo.deadline != nil
                }, set: { value in
                    if value {
                        todo.deadline = todo.deadline ?? Date()
                    } else {
                        todo.deadline = nil
                    }
                    store.save()
                }))
                if let _ = todo.deadline {
                    DatePicker("Due", selection: Binding(get: {
                        todo.deadline ?? Date()
                    }, set: { date in
                        todo.deadline = date
                        store.save()
                    }), displayedComponents: .date)
                }
            }
        }
        .navigationTitle("Edit To-Do")
        .toolbar { EditButton() }
    }

    private func addChecklistItem() {
        let trimmed = newChecklistTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        todo.checklist.append(ChecklistItem(title: trimmed))
        newChecklistTitle = ""
        store.save()
    }

    private func addTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.addTag(trimmed, to: todo.id)
        newTagName = ""
    }
}

#Preview {
    NavigationStack {
        ToDoDetailView(store: DatabaseStore(), todo: .constant(ToDo(title: "Test")))
    }
}
