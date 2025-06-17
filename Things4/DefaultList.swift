import Foundation

public enum DefaultList: String, CaseIterable, Identifiable {
    case inbox
    case today
    case upcoming
    case anytime
    case someday
    case logbook

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .inbox: return "Inbox"
        case .today: return "Today"
        case .upcoming: return "Upcoming"
        case .anytime: return "Anytime"
        case .someday: return "Someday"
        case .logbook: return "Logbook"
        }
    }
}
