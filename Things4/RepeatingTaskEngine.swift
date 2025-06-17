import Foundation

public struct RepeatingTaskEngine {
    public var calendar: Calendar
    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    private func nextStartDate(from startDate: Date?, completionDate: Date, rule: RepeatRule) -> Date {
        let base: Date
        switch rule.type {
        case .on_schedule:
            base = startDate ?? completionDate
        case .after_completion:
            base = completionDate
        }
        switch rule.frequency {
        case .daily:
            return calendar.date(byAdding: .day, value: rule.interval, to: base) ?? base
        case .weekly:
            return calendar.date(byAdding: .day, value: 7 * rule.interval, to: base) ?? base
        case .monthly:
            return calendar.date(byAdding: .month, value: rule.interval, to: base) ?? base
        case .yearly:
            return calendar.date(byAdding: .year, value: rule.interval, to: base) ?? base
        }
    }

    /// Toggle completion for the given task in the database.
    /// If the task has a repeat rule, a new instance is generated when marking it complete.
    public mutating func toggleCompletion(of todoID: UUID, in database: inout Database, today: Date = Date()) {
        guard let index = database.toDos.firstIndex(where: { $0.id == todoID }) else { return }
        if database.toDos[index].status == .completed {
            database.toDos[index].status = .open
            database.toDos[index].completionDate = nil
            return
        }
        database.toDos[index].status = .completed
        database.toDos[index].completionDate = today
        guard let ruleID = database.toDos[index].repeatRuleID,
              let rIndex = database.repeatRules.firstIndex(where: { $0.id == ruleID }),
              let template = try? JSONDecoder().decode(ToDo.self, from: database.repeatRules[rIndex].templateData) else { return }

        let nextStart = nextStartDate(from: database.toDos[index].startDate, completionDate: today, rule: database.repeatRules[rIndex])
        var newTodo = template
        newTodo.id = UUID()
        newTodo.creationDate = today
        newTodo.modificationDate = today
        newTodo.completionDate = nil
        newTodo.status = .open
        newTodo.startDate = nextStart
        newTodo.repeatRuleID = ruleID
        database.toDos.append(newTodo)

        var updatedTemplate = database.toDos[index]
        updatedTemplate.status = .open
        updatedTemplate.completionDate = nil
        if let data = try? JSONEncoder().encode(updatedTemplate) {
            database.repeatRules[rIndex].templateData = data
        }
    }
}
