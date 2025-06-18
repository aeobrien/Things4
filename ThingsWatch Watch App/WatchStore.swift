import SwiftUI

@MainActor
final class WatchStore: ObservableObject {
    @Published var database: Database = .init()
    private var workflow = WorkflowEngine()

    init() {
        Task {
            await SyncManager.shared.subscribeForChanges()
            if let db = try? await SyncManager.shared.load() {
                self.database = db
            }
        }
    }

    func todosToday() -> [ToDo] {
        workflow.tasks(for: .today, in: database)
    }

    func toggle(_ todo: ToDo) {
        guard let idx = database.toDos.firstIndex(where: { $0.id == todo.id }) else { return }
        if database.toDos[idx].status == .open {
            database.toDos[idx].status = .completed
            database.toDos[idx].completionDate = Date()
        } else {
            database.toDos[idx].status = .open
            database.toDos[idx].completionDate = nil
        }
        Task { try? await SyncManager.shared.save(database) }
    }
}
