import Foundation

// Minimal types needed for Widget extension
// TODO: Replace with proper shared framework or package dependency

struct Database: Codable {
    var toDos: [ToDo] = []
    var projects: [Project] = []
    var areas: [Area] = []
}

struct ToDo: Identifiable, Codable {
    let id: UUID
    var title: String
    var status: ToDoStatus
    var completionDate: Date?
    var parentProjectID: UUID?
    var parentAreaID: UUID?
    
    init(id: UUID = UUID(), title: String, status: ToDoStatus = .open) {
        self.id = id
        self.title = title
        self.status = status
    }
}

enum ToDoStatus: String, Codable {
    case open
    case completed
    case cancelled
}

struct Project: Identifiable, Codable {
    let id: UUID
    var title: String
    var parentAreaID: UUID?
}

struct Area: Identifiable, Codable {
    let id: UUID
    var title: String
}

enum DefaultList: String, CaseIterable {
    case today
    case upcoming
    case anytime
    case someday
    case inbox
    case logbook
    
    var title: String {
        switch self {
        case .today: return "Today"
        case .upcoming: return "Upcoming"
        case .anytime: return "Anytime"
        case .someday: return "Someday"
        case .inbox: return "Inbox"
        case .logbook: return "Logbook"
        }
    }
}

// Simplified sync manager for Widget
final class SyncManager {
    static let shared = SyncManager()
    
    private init() {}
    
    func load() async throws -> Database {
        // TODO: Load from shared container/CloudKit
        return Database()
    }
    
    func save(_ database: Database) async throws {
        // TODO: Save to shared container/CloudKit
    }
}

// Simplified workflow engine for Widget
final class WorkflowEngine {
    func tasks(for list: DefaultList, in database: Database) -> [ToDo] {
        switch list {
        case .today:
            // TODO: Implement proper filtering logic
            return database.toDos.filter { $0.status == .open }
        default:
            return []
        }
    }
}