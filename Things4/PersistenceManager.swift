import Foundation

/// Singleton responsible for persisting and loading the database.
public actor PersistenceManager {
    public static let shared = PersistenceManager()

    private let fileURL: URL

    public init(fileURL: URL? = nil) {
        if let url = fileURL {
            self.fileURL = url
        } else {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.fileURL = directory.appendingPathComponent("database.json")
        }
    }

    /// Save the provided database to disk.
    public func save(_ database: Database) async throws {
        let data = try JSONEncoder().encode(database)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Load the database from disk.
    public func load() async throws -> Database {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return Database()
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Database.self, from: data)
    }
}
