import Foundation

public enum Status: String, Codable, Sendable {
    case open
    case completed
    case canceled
}

public struct ChecklistItem: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var isCompleted: Bool

    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

public struct Tag: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String

    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

public struct ToDo: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var notes: String
    public var creationDate: Date
    public var modificationDate: Date
    public var completionDate: Date?
    public var status: Status
    public var startDate: Date?
    public var isEvening: Bool
    public var isSomeday: Bool
    public var deadline: Date?
    public var checklist: [ChecklistItem]
    public var tagIDs: [UUID]
    public var parentProjectID: UUID?
    public var parentAreaID: UUID?
    public var headingID: UUID?

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        creationDate: Date = Date(),
        modificationDate: Date = Date(),
        completionDate: Date? = nil,
        status: Status = .open,
        startDate: Date? = nil,
        isEvening: Bool = false,
        isSomeday: Bool = false,
        deadline: Date? = nil,
        checklist: [ChecklistItem] = [],
        tagIDs: [UUID] = [],
        parentProjectID: UUID? = nil,
        parentAreaID: UUID? = nil,
        headingID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.completionDate = completionDate
        self.status = status
        self.startDate = startDate
        self.isEvening = isEvening
        self.isSomeday = isSomeday
        self.deadline = deadline
        self.checklist = checklist
        self.tagIDs = tagIDs
        self.parentProjectID = parentProjectID
        self.parentAreaID = parentAreaID
        self.headingID = headingID
    }
}

public struct Project: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var notes: String
    public var creationDate: Date
    public var modificationDate: Date
    public var completionDate: Date?
    public var status: Status
    public var startDate: Date?
    public var isEvening: Bool
    public var deadline: Date?
    public var tagIDs: [UUID]
    public var parentAreaID: UUID?

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        creationDate: Date = Date(),
        modificationDate: Date = Date(),
        completionDate: Date? = nil,
        status: Status = .open,
        startDate: Date? = nil,
        isEvening: Bool = false,
        deadline: Date? = nil,
        tagIDs: [UUID] = [],
        parentAreaID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.completionDate = completionDate
        self.status = status
        self.startDate = startDate
        self.isEvening = isEvening
        self.deadline = deadline
        self.tagIDs = tagIDs
        self.parentAreaID = parentAreaID
    }
}

public struct Area: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var creationDate: Date
    public var modificationDate: Date
    public var tagIDs: [UUID]

    public init(
        id: UUID = UUID(),
        title: String,
        creationDate: Date = Date(),
        modificationDate: Date = Date(),
        tagIDs: [UUID] = []
    ) {
        self.id = id
        self.title = title
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.tagIDs = tagIDs
    }
}

public struct Heading: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var creationDate: Date
    public var modificationDate: Date
    public var completionDate: Date?
    public var status: Status
    public var parentProjectID: UUID

    public init(
        id: UUID = UUID(),
        title: String,
        creationDate: Date = Date(),
        modificationDate: Date = Date(),
        completionDate: Date? = nil,
        status: Status = .open,
        parentProjectID: UUID
    ) {
        self.id = id
        self.title = title
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.completionDate = completionDate
        self.status = status
        self.parentProjectID = parentProjectID
    }
}

public enum RepeatType: String, Codable, Sendable {
    case on_schedule
    case after_completion
}

public enum Frequency: String, Codable, Sendable {
    case daily
    case weekly
    case monthly
    case yearly
}

public enum DayOfWeek: String, Codable, CaseIterable, Sendable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

public struct RepeatRule: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var type: RepeatType
    public var frequency: Frequency
    public var interval: Int
    public var weekdays: [DayOfWeek]?
    public var templateData: Data

    public init(
        id: UUID = UUID(),
        type: RepeatType,
        frequency: Frequency,
        interval: Int = 1,
        weekdays: [DayOfWeek]? = nil,
        templateData: Data
    ) {
        self.id = id
        self.type = type
        self.frequency = frequency
        self.interval = interval
        self.weekdays = weekdays
        self.templateData = templateData
    }
}

public struct Database: Codable, Equatable, Sendable {
    public var toDos: [ToDo]
    public var projects: [Project]
    public var areas: [Area]
    public var headings: [Heading]
    public var tags: [Tag]
    public var repeatRules: [RepeatRule]

    public init(
        toDos: [ToDo] = [],
        projects: [Project] = [],
        areas: [Area] = [],
        headings: [Heading] = [],
        tags: [Tag] = [],
        repeatRules: [RepeatRule] = []
    ) {
        self.toDos = toDos
        self.projects = projects
        self.areas = areas
        self.headings = headings
        self.tags = tags
        self.repeatRules = repeatRules
    }
}
