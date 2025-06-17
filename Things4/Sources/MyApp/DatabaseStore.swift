import SwiftUI
import Things4

@MainActor
final class DatabaseStore: ObservableObject {
    @Published var database: Database = .init()

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
        case .list(.inbox):
            return database.toDos.filter { $0.parentProjectID == nil && $0.parentAreaID == nil && $0.status == .open }
        case .list:
            return database.toDos // For other default lists return all for now
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

    private func save() {
        Task { try? await PersistenceManager.shared.save(database) }
    }
}
