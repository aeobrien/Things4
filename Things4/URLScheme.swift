import Foundation

public enum URLScheme {
    public static let scheme = "things4"

    /// Handle a URL in the custom scheme, mutating the database if appropriate.
    @discardableResult
    public static func handle(_ url: URL, database: inout Database) -> Bool {
        guard url.scheme?.lowercased() == scheme else { return false }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
        let action = (components.host ?? components.path.replacingOccurrences(of: "/", with: "")).lowercased()
        switch action {
        case "add":
            let title = components.queryItems?.first { $0.name == "title" }?.value ?? "New To-Do"
            let notes = components.queryItems?.first { $0.name == "notes" }?.value ?? ""
            var todo = ToDo(title: title, notes: notes)
            if let when = components.queryItems?.first(where: { $0.name == "when" })?.value,
               let date = ISO8601DateFormatter().date(from: when) {
                todo.startDate = date
            }
            if let deadline = components.queryItems?.first(where: { $0.name == "deadline" })?.value,
               let date = ISO8601DateFormatter().date(from: deadline) {
                todo.deadline = date
            }
            database.toDos.append(todo)
            return true
        default:
            return false
        }
    }
}
