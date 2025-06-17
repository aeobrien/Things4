import Foundation
import Testing
@testable import Things4

struct DataModelTests {
    @Test
    func testModelCodable() throws {
        let todo = ToDo(title: "Test")
        let data = try JSONEncoder().encode(todo)
        let decoded = try JSONDecoder().decode(ToDo.self, from: data)
        #expect(decoded.title == todo.title)
    }

    @Test
    func testProjectCodable() throws {
        let project = Project(title: "Project")
        let data = try JSONEncoder().encode(project)
        let decoded = try JSONDecoder().decode(Project.self, from: data)
        #expect(decoded.title == project.title)
    }

    @Test
    func testAreaCodable() throws {
        let area = Area(title: "Area")
        let data = try JSONEncoder().encode(area)
        let decoded = try JSONDecoder().decode(Area.self, from: data)
        #expect(decoded.title == area.title)
    }

    @Test
    func testHeadingCodable() throws {
        let heading = Heading(title: "Heading", parentProjectID: UUID())
        let data = try JSONEncoder().encode(heading)
        let decoded = try JSONDecoder().decode(Heading.self, from: data)
        #expect(decoded.title == heading.title)
    }

    @Test
    func testTagCodable() throws {
        let tag = Things4.Tag(name: "Tag")
        let data = try JSONEncoder().encode(tag)
        let decoded = try JSONDecoder().decode(Things4.Tag.self, from: data)
        #expect(decoded.name == tag.name)
    }
}
