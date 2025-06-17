import Foundation

public struct WorkflowEngine {
    public var calendar: Calendar
    public var today: Date

    public init(calendar: Calendar = .current, today: Date = Date()) {
        self.calendar = calendar
        self.today = calendar.startOfDay(for: today)
    }

    private func isToday(_ date: Date?) -> Bool {
        guard let date else { return false }
        return calendar.isDate(date, inSameDayAs: today)
    }

    public func tasks(for list: DefaultList, in database: Database) -> [ToDo] {
        switch list {
        case .inbox:
            return database.toDos.filter { $0.parentProjectID == nil && $0.parentAreaID == nil && $0.status == .open }
        case .today:
            return database.toDos.filter { todo in
                guard todo.status == .open else { return false }
                if let start = todo.startDate, start <= today { return true }
                if isToday(todo.deadline) { return true }
                return false
            }
        case .upcoming:
            return database.toDos.filter { todo in
                guard todo.status == .open else { return false }
                if let start = todo.startDate, start > today { return true }
                return false
            }.sorted { ($0.startDate ?? Date.distantFuture) < ($1.startDate ?? Date.distantFuture) }
        case .anytime:
            let todayList = tasks(for: .today, in: database)
            let idsToday = Set(todayList.map { $0.id })
            return database.toDos.filter { todo in
                todo.status == .open && todo.startDate == nil && !todo.isSomeday && !idsToday.contains(todo.id)
            }
        case .someday:
            return database.toDos.filter { $0.status == .open && $0.isSomeday }
        case .logbook:
            return database.toDos.filter { $0.status == .completed }
                .sorted { ($0.completionDate ?? Date.distantPast) > ($1.completionDate ?? Date.distantPast) }
        }
    }

    public func progress(for projectID: UUID, in database: Database) -> Double {
        let tasks = database.toDos.filter { $0.parentProjectID == projectID && $0.status != .canceled }
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.status == .completed }.count
        return Double(completed) / Double(tasks.count)
    }
}
