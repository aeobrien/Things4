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
    private let subscriptionID = "database-changes"
#endif

    public init(persistence: PersistenceManager = PersistenceManager()) {
        self.persistence = persistence
#if canImport(CloudKit)
        // Use a specific container identifier to avoid nil container issues
        let container = CKContainer(identifier: "iCloud.AOTondra.Things4")
        self.database = container.privateCloudDatabase
#endif
    }

#if canImport(CloudKit)
    public init(persistence: PersistenceManager = PersistenceManager(), container: CKContainer) {
        self.persistence = persistence
        self.database = container.privateCloudDatabase
    }
#endif

    /// Ensure a subscription exists so we receive push notifications for changes in CloudKit
    public func subscribeForChanges() async {
#if canImport(CloudKit)
        let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
        subscription.notificationInfo = {
            let info = CKSubscription.NotificationInfo()
            info.shouldSendContentAvailable = true
            return info
        }()
        do {
            _ = try await database.save(subscription)
        } catch {
            // Ignore errors like "already exists"
        }
#endif
    }

    public func save(_ databaseData: Database) async throws {
#if canImport(CloudKit)
        try await saveToCloudKit(databaseData)
        try? await persistence.save(databaseData)
#else
        try await persistence.save(databaseData)
#endif
    }

    public func load() async throws -> Database {
#if canImport(CloudKit)
        if let db = try await loadFromCloudKit() {
            try? await persistence.save(db)
            return db
        }
        return try await persistence.load()
#else
        return try await persistence.load()
#endif
    }

    /// Handle a CloudKit push notification by fetching the latest data.
    public func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) async {
#if canImport(CloudKit)
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKDatabaseNotification,
              notification.subscriptionID == subscriptionID else { return }
        if let db = try? await loadFromCloudKit() {
            try? await persistence.save(db)
        }
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