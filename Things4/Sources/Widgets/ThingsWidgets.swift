import WidgetKit
import SwiftUI
import Things4

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todos: [ToDo]
    let progress: Double
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todos: [], progress: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            let db = (try? await SyncManager.shared.load()) ?? Database()
            let engine = WorkflowEngine()
            let todos = engine.tasks(for: .today, in: db)
            let completed = todos.filter { $0.status == .completed }.count
            let progress = todos.isEmpty ? 0 : Double(completed) / Double(todos.count)
            completion(SimpleEntry(date: Date(), todos: Array(todos.prefix(3)), progress: progress))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let db = (try? await SyncManager.shared.load()) ?? Database()
            let engine = WorkflowEngine()
            let todos = engine.tasks(for: .today, in: db)
            let completed = todos.filter { $0.status == .completed }.count
            let progress = todos.isEmpty ? 0 : Double(completed) / Double(todos.count)
            let entry = SimpleEntry(date: Date(), todos: Array(todos.prefix(3)), progress: progress)
            completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60*15))))
        }
    }
}

struct TodayListWidgetEntryView: View {
    var entry: Provider.Entry
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
    var entry: Provider.Entry
    var body: some View {
        Gauge(value: entry.progress) {
            Text("Today")
        }
        .gaugeStyle(.accessoryCircular)
        .padding()
    }
}

@main
struct ThingsWidgets: WidgetBundle {
    var body: some Widget {
        TodayListWidget()
        ProgressRingWidget()
        AddTodoWidget()
    }
}

struct TodayListWidget: Widget {
    let kind = "TodayListWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ProgressRingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today Progress")
        .description("Shows progress of today's tasks.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
    }
}

struct AddTodoWidget: Widget {
    let kind = "AddTodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
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
