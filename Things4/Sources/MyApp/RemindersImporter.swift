import Foundation
import SwiftUI

struct PendingReminder: Identifiable, Hashable {
    var id: String { identifier }
    let identifier: String
    let title: String
    let dueDate: Date?
}

#if canImport(EventKit)
import EventKit

@MainActor
final class RemindersImporter: ObservableObject {
    static let shared = RemindersImporter()
    private let store = EKEventStore()
    @Published private(set) var reminders: [PendingReminder] = []
    private var map: [String: EKReminder] = [:]
    var listIdentifier: String? {
        get { UserDefaults.standard.string(forKey: "remindersListID") }
        set { UserDefaults.standard.setValue(newValue, forKey: "remindersListID") }
    }

    init() {
        Task { await requestAccess() }
    }

    func requestAccess() async {
        do {
            try await store.requestAccess(to: .reminder)
        } catch { }
    }

    func loadReminders() async {
        guard let id = listIdentifier,
              let calendar = store.calendar(withIdentifier: id) else { return }
        let predicate = store.predicateForReminders(in: [calendar])
        let items = try? await store.fetchReminders(matching: predicate)
        map = [:]
        reminders = (items ?? []).map { r in
            map[r.calendarItemIdentifier] = r
            return PendingReminder(identifier: r.calendarItemIdentifier, title: r.title ?? "", dueDate: r.dueDateComponents?.date)
        }
    }

    func importReminder(_ id: String, into store: DatabaseStore) async {
        guard let reminder = map[id] else { return }
        var todo = ToDo(title: reminder.title ?? "")
        todo.deadline = reminder.dueDateComponents?.date
        store.database.toDos.append(todo)
        store.save()
        try? self.store.remove(reminder, commit: true)
        map[id] = nil
        reminders.removeAll { $0.identifier == id }
    }
}
#else
@MainActor
final class RemindersImporter: ObservableObject {
    static let shared = RemindersImporter()
    @Published private(set) var reminders: [PendingReminder] = []
    var listIdentifier: String?
    init() {}
    func requestAccess() async {}
    func loadReminders() async {}
    func importReminder(_ id: String, into store: DatabaseStore) async {}
}
#endif
