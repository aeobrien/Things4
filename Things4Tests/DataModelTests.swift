import Foundation
<<<<<<< codex/refer-to-bible.txt-for-instructions
import XCTest
@testable import Things4

final class DataModelTests: XCTestCase {
=======
import Testing
@testable import Things4

struct DataModelTests {
    @Test
>>>>>>> main
    func testModelCodable() throws {
        let todo = ToDo(title: "Test")
        let data = try JSONEncoder().encode(todo)
        let decoded = try JSONDecoder().decode(ToDo.self, from: data)
<<<<<<< codex/refer-to-bible.txt-for-instructions
        XCTAssertEqual(decoded.title, todo.title)
    }

=======
        #expect(decoded.title == todo.title)
    }

    @Test
>>>>>>> main
    func testProjectCodable() throws {
        let project = Project(title: "Project")
        let data = try JSONEncoder().encode(project)
        let decoded = try JSONDecoder().decode(Project.self, from: data)
<<<<<<< codex/refer-to-bible.txt-for-instructions
        XCTAssertEqual(decoded.title, project.title)
    }

=======
        #expect(decoded.title == project.title)
    }

    @Test
>>>>>>> main
    func testAreaCodable() throws {
        let area = Area(title: "Area")
        let data = try JSONEncoder().encode(area)
        let decoded = try JSONDecoder().decode(Area.self, from: data)
<<<<<<< codex/refer-to-bible.txt-for-instructions
        XCTAssertEqual(decoded.title, area.title)
    }

=======
        #expect(decoded.title == area.title)
    }

    @Test
>>>>>>> main
    func testHeadingCodable() throws {
        let heading = Heading(title: "Heading", parentProjectID: UUID())
        let data = try JSONEncoder().encode(heading)
        let decoded = try JSONDecoder().decode(Heading.self, from: data)
<<<<<<< codex/refer-to-bible.txt-for-instructions
        XCTAssertEqual(decoded.title, heading.title)
    }

    func testTagCodable() throws {
        let tag = Tag(name: "Tag")
        let data = try JSONEncoder().encode(tag)
        let decoded = try JSONDecoder().decode(Tag.self, from: data)
        XCTAssertEqual(decoded.name, tag.name)
=======
        #expect(decoded.title == heading.title)
    }

    @Test
    func testTagCodable() throws {
        let tag = Things4.Tag(name: "Tag")
        let data = try JSONEncoder().encode(tag)
        let decoded = try JSONDecoder().decode(Things4.Tag.self, from: data)
        #expect(decoded.name == tag.name)
>>>>>>> main
    }
}
