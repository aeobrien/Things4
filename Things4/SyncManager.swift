import Foundation
#if canImport(CloudKit)
import CloudKit
#endif

/// Manages saving and loading the database either locally or via CloudKit.
public actor SyncManager {
    public static let shared = SyncManager()

    private let persistence: PersistenceManager

#if canImport(CloudKit)
    private let database: CKDatabase
#endif

    public init(persistence: PersistenceManager = PersistenceManager()) {
        self.persistence = persistence
#if canImport(CloudKit)
        self.database = CKContainer.default().privateCloudDatabase
#endif
    }

#if canImport(CloudKit)
    public init(persistence: PersistenceManager = PersistenceManager(), container: CKContainer) {
        self.persistence = persistence
        self.database = container.privateCloudDatabase
    }
#endif

    public func save(_ databaseData: Database) async throws {
#if canImport(CloudKit)
        try await saveToCloudKit(databaseData)
#else
        try await persistence.save(databaseData)
#endif
    }

    public func load() async throws -> Database {
#if canImport(CloudKit)
        if let db = try await loadFromCloudKit() {
            return db
        }
        return Database()
#else
        return try await persistence.load()
#endif
    }

#if canImport(CloudKit)
    private func saveToCloudKit(_ databaseData: Database) async throws {
        let data = try JSONEncoder().encode(databaseData)
        let recordID = CKRecord.ID(recordName: "database")
        let record = CKRecord(recordType: "Database", recordID: recordID)
        record["data"] = data as CKRecordValue
        _ = try await database.save(record)
    }

    private func loadFromCloudKit() async throws -> Database? {
        let recordID = CKRecord.ID(recordName: "database")
        do {
            let record = try await database.record(for: recordID)
            if let data = record["data"] as? Data {
                return try JSONDecoder().decode(Database.self, from: data)
            }
            return nil
        } catch {
            return nil
        }
    }
#endif
}
