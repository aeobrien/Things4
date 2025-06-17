import XCTest
@testable import Things4

final class RepeatingTaskEngineTests: XCTestCase {
    func testMonthlyOnSchedule() {
        var db = Database()
        let cal = Calendar(identifier: .gregorian)
        let start = cal.date(from: DateComponents(year: 2024, month: 6, day: 1))!
        var todo = ToDo(title: "Pay Rent", startDate: start)
        let rule = RepeatRule(type: .on_schedule, frequency: .monthly, templateData: try! JSONEncoder().encode(todo))
        todo.repeatRuleID = rule.id
        db.toDos = [todo]
        db.repeatRules = [rule]
        var engine = RepeatingTaskEngine(calendar: cal)
        engine.toggleCompletion(of: todo.id, in: &db, today: start)
        XCTAssertEqual(db.toDos.count, 2)
        let nextStart = cal.date(byAdding: .month, value: 1, to: start)!
        XCTAssertEqual(db.toDos[1].startDate, nextStart)
    }

    func testAfterCompletion() {
        var db = Database()
        let cal = Calendar(identifier: .gregorian)
        let today = cal.startOfDay(for: Date())
        var todo = ToDo(title: "Water Plants")
        let rule = RepeatRule(type: .after_completion, frequency: .daily, interval: 3, templateData: try! JSONEncoder().encode(todo))
        todo.repeatRuleID = rule.id
        db.toDos = [todo]
        db.repeatRules = [rule]
        var engine = RepeatingTaskEngine(calendar: cal)
        engine.toggleCompletion(of: todo.id, in: &db, today: today)
        XCTAssertEqual(db.toDos.count, 2)
        let expected = cal.date(byAdding: .day, value: 3, to: today)!
        XCTAssertEqual(db.toDos[1].startDate, expected)
    }

    func testTemplateUpdated() {
        var db = Database()
        let cal = Calendar(identifier: .gregorian)
        var todo = ToDo(title: "Water")
        let rule = RepeatRule(type: .after_completion, frequency: .daily, templateData: try! JSONEncoder().encode(todo))
        todo.repeatRuleID = rule.id
        db.toDos = [todo]
        db.repeatRules = [rule]
        var updatedTemplate = todo
        updatedTemplate.title = "Water Plants"
        db.repeatRules[0].templateData = try! JSONEncoder().encode(updatedTemplate)

        var engine = RepeatingTaskEngine(calendar: cal)
        engine.toggleCompletion(of: todo.id, in: &db, today: cal.startOfDay(for: Date()))
        XCTAssertEqual(db.toDos[1].title, "Water Plants")
    }
}
