import Foundation

#if canImport(Intents)
import Intents
#endif
#if canImport(AppIntents)
import AppIntents
#endif

/// Lightweight wrappers for Siri intents and App Shortcuts.
public enum SiriShortcuts {
    /// Donate a simple intent when a new to-do is created.
    public static func donateAddIntent(_ todo: ToDo) {
        #if canImport(Intents)
        let intent = INAddTasksIntent(targetTaskList: nil, taskTitles: [INSpeakableString(spokenPhrase: todo.title)], spatialEventTrigger: nil, temporalEventTrigger: nil, priority: .notFlagged)
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate(completion: nil)
        #endif
    }

    /// Provide basic shortcuts for creating a to-do.
    #if canImport(AppIntents)
    @available(iOS 16.0, macOS 13.0, *)
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: AddTaskIntent(), phrases: ["Add task with \(.title)"])!.intoArray()
    }
    #else
    public static var appShortcuts: [String] { [] }
    #endif
}

#if canImport(AppIntents)
@available(iOS 16.0, macOS 13.0, *)
struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add To-Do"
    @Parameter var title: String
    @Parameter var notes: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add a to-do named \(.title)")
    }

    func perform() async throws -> some IntentResult {
        var db = try await SyncManager.shared.load()
        db.toDos.append(ToDo(title: title, notes: notes ?? ""))
        try await SyncManager.shared.save(db)
        return .result()
    }
}
#endif

#if canImport(AppIntents)
extension AppShortcut {
    fileprivate func intoArray() -> [AppShortcut] { [self] }
}
#endif
