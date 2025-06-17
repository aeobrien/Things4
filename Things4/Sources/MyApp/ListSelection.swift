import Foundation
import Things4

enum ListSelection: Hashable, Identifiable {
    case list(DefaultList)
    case area(UUID)
    case project(UUID)

    var id: String {
        switch self {
        case .list(let list):
            return "list-\(list.rawValue)"
        case .area(let id):
            return "area-\(id.uuidString)"
        case .project(let id):
            return "project-\(id.uuidString)"
        }
    }

    func title(in database: Database) -> String {
        switch self {
        case .list(let list):
            return list.title
        case .area(let id):
            return database.areas.first(where: { $0.id == id })?.title ?? ""
        case .project(let id):
            return database.projects.first(where: { $0.id == id })?.title ?? ""
        }
    }
}
