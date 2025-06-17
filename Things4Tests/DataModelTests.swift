import Foundation
import XCTest
@testable import Things4

final class DataModelTests: XCTestCase {
    func testModelCodable() throws {
        let todo = ToDo(title: "Test")
        let data = try JSONEncoder().encode(todo)
        let decoded = try JSONDecoder().decode(ToDo.self, from: data)
        XCTAssertEqual(decoded.title, todo.title)
    }

    func testProjectCodable() throws {
        let project = Project(title: "Project")
        let data = try JSONEncoder().encode(project)
        let decoded = try JSONDecoder().decode(Project.self, from: data)
        XCTAssertEqual(decoded.title, project.title)
    }

    func testAreaCodable() throws {
        let area = Area(title: "Area")
        let data = try JSONEncoder().encode(area)
        let decoded = try JSONDecoder().decode(Area.self, from: data)
        XCTAssertEqual(decoded.title, area.title)
    }

    func testHeadingCodable() throws {
        let heading = Heading(title: "Heading", parentProjectID: UUID())
        let data = try JSONEncoder().encode(heading)
        let decoded = try JSONDecoder().decode(Heading.self, from: data)
        XCTAssertEqual(decoded.title, heading.title)
    }

    func testTagCodable() throws {
        let tag = Tag(name: "Tag")
        let data = try JSONEncoder().encode(tag)
        let decoded = try JSONDecoder().decode(Tag.self, from: data)
        XCTAssertEqual(decoded.name, tag.name)
    }
}
