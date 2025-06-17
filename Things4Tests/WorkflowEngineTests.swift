import XCTest
@testable import Things4

final class WorkflowEngineTests: XCTestCase {
    func testDefaultLists() {
        var db = Database()
        let cal = Calendar(identifier: .gregorian)
        let today = cal.startOfDay(for: Date())
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        let projectID = UUID()
        db.toDos = [
            ToDo(title: "Inbox"),
            ToDo(title: "TodayStart", startDate: yesterday, parentProjectID: projectID),
            ToDo(title: "Deadline", deadline: today, parentProjectID: projectID),
            ToDo(title: "Future", startDate: tomorrow, parentProjectID: projectID),
            ToDo(title: "Someday", isSomeday: true, parentProjectID: projectID),
            ToDo(title: "Done", completionDate: today, status: .completed, parentProjectID: projectID)
        ]

        let engine = WorkflowEngine(calendar: cal, today: today)
        XCTAssertEqual(engine.tasks(for: .inbox, in: db).count, 1)
        XCTAssertEqual(engine.tasks(for: .today, in: db).map { $0.title }.sorted(), ["Deadline", "TodayStart"])
        XCTAssertEqual(engine.tasks(for: .upcoming, in: db).map { $0.title }, ["Future"])
        XCTAssertEqual(engine.tasks(for: .anytime, in: db).map { $0.title }, ["Inbox"])
        XCTAssertEqual(engine.tasks(for: .someday, in: db).map { $0.title }, ["Someday"])
        XCTAssertEqual(engine.tasks(for: .logbook, in: db).map { $0.title }, ["Done"])
    }
}
