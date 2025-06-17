import XCTest
@testable import Things4

final class ProjectProgressTests: XCTestCase {
    func testProgressCalculation() {
        let project = Project(title: "Proj")
        let todos = [
            ToDo(title: "A", parentProjectID: project.id),
            ToDo(title: "B", status: .completed, parentProjectID: project.id),
            ToDo(title: "C")
        ]
        let db = Database(toDos: todos, projects: [project])
        let engine = WorkflowEngine()
        XCTAssertEqual(engine.progress(for: project.id, in: db), 0.5)
    }
}
