import SwiftUI
import Things4

@MainActor
final class DatabaseStore: ObservableObject {
    @Published var database: Database = .init()
    private var workflow = WorkflowEngine()

    init() {
        Task {
            do {
                database = try await PersistenceManager.shared.load()
                if database.areas.isEmpty && database.projects.isEmpty && database.toDos.isEmpty {
                    database = SampleData.database
                }
            } catch {
                database = SampleData.database
            }
        }
    }

    func filteredToDos(selection: ListSelection) -> [ToDo] {
        switch selection {
        case .list(let list):
            return workflow.tasks(for: list, in: database)
        case .project(let id):
            return database.toDos.filter { $0.parentProjectID == id }
        case .area(let id):
            return database.toDos.filter { $0.parentAreaID == id }
        }
    }

    func addTodo(to selection: ListSelection) {
        var todo = ToDo(title: "New To-Do")
        switch selection {
        case .project(let id):
            todo.parentProjectID = id
        case .area(let id):
            todo.parentAreaID = id
        case .list:
            break
        }
        database.toDos.append(todo)
        save()
    }

    func toggleCompletion(for todoID: UUID) {
        guard let index = database.toDos.firstIndex(where: { $0.id == todoID }) else { return }
        if database.toDos[index].status == .completed {
            database.toDos[index].status = .open
            database.toDos[index].completionDate = nil
        } else {
            database.toDos[index].status = .completed
            database.toDos[index].completionDate = Date()
        }
        save()
    }

    func deleteTodo(at offsets: IndexSet, selection: ListSelection) {
        let tasks = filteredToDos(selection: selection)
        let ids = offsets.map { tasks[$0].id }
        database.toDos.removeAll { ids.contains($0.id) }
        save()
    }

    func save() {
        Task { try? await PersistenceManager.shared.save(database) }
    }

    func binding(for todoID: UUID) -> Binding<ToDo> {
        Binding {
            self.database.toDos.first(where: { $0.id == todoID }) ?? ToDo(title: "")
        } set: { newValue in
            if let index = self.database.toDos.firstIndex(where: { $0.id == todoID }) {
                self.database.toDos[index] = newValue
                self.save()
            }
        }
    }

    func addTag(_ name: String, to todoID: UUID) {
        let tag: Tag
        if let existing = database.tags.first(where: { $0.name.lowercased() == name.lowercased() }) {
            tag = existing
        } else {
            tag = Tag(name: name)
            database.tags.append(tag)
        }
        guard let index = database.toDos.firstIndex(where: { $0.id == todoID }) else { return }
        if !database.toDos[index].tagIDs.contains(tag.id) {
            database.toDos[index].tagIDs.append(tag.id)
            save()
        }
    }

    func removeTag(_ tagID: UUID, from todoID: UUID) {
        guard let index = database.toDos.firstIndex(where: { $0.id == todoID }) else { return }
        database.toDos[index].tagIDs.removeAll { $0 == tagID }
        save()
    }
}