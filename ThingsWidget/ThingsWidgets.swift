import WidgetKit
import SwiftUI

struct TodoEntry: TimelineEntry {
    let date: Date
    let todos: [ToDo]
    let progress: Double
}

struct TodoProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: Date(), todos: [], progress: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        Task {
            let db = (try? await SyncManager.shared.load()) ?? Database()
            let engine = WorkflowEngine()
            let todos = engine.tasks(for: .today, in: db)
            let completed = todos.filter { $0.status == .completed }.count
            let progress = todos.isEmpty ? 0 : Double(completed) / Double(todos.count)
            completion(TodoEntry(date: Date(), todos: Array(todos.prefix(3)), progress: progress))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        Task {
            let db = (try? await SyncManager.shared.load()) ?? Database()
            let engine = WorkflowEngine()
            let todos = engine.tasks(for: .today, in: db)
            let completed = todos.filter { $0.status == .completed }.count
            let progress = todos.isEmpty ? 0 : Double(completed) / Double(todos.count)
            let entry = TodoEntry(date: Date(), todos: Array(todos.prefix(3)), progress: progress)
            completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60*15))))
        }
    }
}

struct TodayListWidgetEntryView: View {
    var entry: TodoProvider.Entry
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(entry.todos) { todo in
                HStack {
                    Image(systemName: todo.status == .completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.status == .completed ? .green : .gray)
                    Text(todo.title).lineLimit(1)
                }
            }
            if entry.todos.isEmpty {
                Text("All done!")
            }
        }
        .padding()
    }
}

struct ProgressRingWidgetEntryView: View {
    var entry: TodoProvider.Entry
    var body: some View {
        Gauge(value: entry.progress) {
            Text("Today")
        }
        #if os(watchOS) || os(iOS)
        .gaugeStyle(.accessoryCircular)
        #else
        .gaugeStyle(.linearCapacity)
        #endif
        .padding()
    }
}


struct TodayListWidget: Widget {
    let kind = "TodayListWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            TodayListWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today List")
        .description("Shows your next tasks from Today.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ProgressRingWidget: Widget {
    let kind = "ProgressRingWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            ProgressRingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today Progress")
        .description("Shows progress of today's tasks.")
        .supportedFamilies(supportedFamiliesForProgressWidget())
    }
}

func supportedFamiliesForProgressWidget() -> [WidgetFamily] {
    #if os(watchOS) || os(iOS)
    return [.accessoryCircular, .accessoryRectangular, .systemSmall]
    #else
    return [.systemSmall]
    #endif
}

struct AddTodoWidget: Widget {
    let kind = "AddTodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { _ in
            Link(destination: URL(string: "things4://add")!) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                    Text("New To-Do")
                }
            }
        }
        .configurationDisplayName("New To-Do")
        .description("Quickly add a new task.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
