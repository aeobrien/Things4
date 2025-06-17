import Foundation
import XCTest
@testable import Things4

final class SyncManagerTests: XCTestCase {
    func testSaveAndLoad() async throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let manager = SyncManager(persistence: PersistenceManager(fileURL: tmp))

        var database = Database()
        database.areas = [Area(title: "A1"), Area(title: "A2")]
        database.projects = [Project(title: "P1"), Project(title: "P2"), Project(title: "P3")]
        database.toDos = (1...10).map { ToDo(title: "Task \($0)") }

        try await manager.save(database)

        let loaded = try await manager.load()
        XCTAssertEqual(loaded, database)
    }

    func testLoadNonExistentReturnsEmpty() async throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let manager = SyncManager(persistence: PersistenceManager(fileURL: tmp))
        let db = try await manager.load()
        XCTAssertTrue(db.toDos.isEmpty)
    }
}

