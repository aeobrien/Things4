import XCTest
@testable import Things4

final class URLSchemeTests: XCTestCase {
    func testAddTodoFromURL() {
        var db = Database()
        let url = URL(string: "things4://add?title=Hello")!
        XCTAssertTrue(URLScheme.handle(url, database: &db))
        XCTAssertEqual(db.toDos.first?.title, "Hello")
    }

    func testInvalidScheme() {
        var db = Database()
        let url = URL(string: "https://example.com")!
        XCTAssertFalse(URLScheme.handle(url, database: &db))
        XCTAssertTrue(db.toDos.isEmpty)
    }
}
