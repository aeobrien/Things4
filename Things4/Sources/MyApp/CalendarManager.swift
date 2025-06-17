import Foundation
import SwiftUI

struct CalendarEvent: Identifiable, Hashable {
    var id: String { identifier }
    let identifier: String
    let title: String
    let startDate: Date
    let endDate: Date
}

#if canImport(EventKit)
import EventKit

@MainActor
final class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    private let store = EKEventStore()
    @Published private(set) var events: [CalendarEvent] = []

    init() {
        Task { await requestAccess() }
    }
    
    func requestAccess() async {
        do {
            try await store.requestAccess(to: .event)
        } catch {
            // ignore errors
        }
    }
    
    func loadUpcomingEvents(days: Int = 30) async {
        guard UserDefaults.standard.bool(forKey: "calendarEnabled") else { return }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: days, to: start) ?? start
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let ekEvents = store.events(matching: predicate)
        events = ekEvents.map { e in
            CalendarEvent(identifier: e.eventIdentifier, title: e.title ?? "", startDate: e.startDate, endDate: e.endDate)
        }
    }
    
    func events(forDay date: Date) -> [CalendarEvent] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start
        return events.filter { $0.startDate >= start && $0.startDate < end }
            .sorted { $0.startDate < $1.startDate }
    }
    
    func upcomingEvents(after date: Date) -> [CalendarEvent] {
        events.filter { $0.startDate > date }.sorted { $0.startDate < $1.startDate }
    }
}
#else
@MainActor
final class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    @Published private(set) var events: [CalendarEvent] = []
    init() {}
    func requestAccess() async {}
    func loadUpcomingEvents(days: Int = 30) async {}
    func events(forDay date: Date) -> [CalendarEvent] { [] }
    func upcomingEvents(after date: Date) -> [CalendarEvent] { [] }
}
#endif
