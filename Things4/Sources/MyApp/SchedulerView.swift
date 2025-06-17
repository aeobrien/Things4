import SwiftUI
import Things4

struct SchedulerView: View {
    @Binding var todo: ToDo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Someday", isOn: Binding(get: { todo.isSomeday }, set: { newValue in
                    todo.isSomeday = newValue
                    if newValue { todo.startDate = nil }
                }))
                Toggle("Has Start Date", isOn: Binding(get: { todo.startDate != nil }, set: { value in
                    if value { todo.startDate = todo.startDate ?? Date() } else { todo.startDate = nil }
                }))
                if todo.startDate != nil {
                    DatePicker("Start", selection: Binding(get: { todo.startDate ?? Date() }, set: { todo.startDate = $0 }), displayedComponents: .date)
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

#Preview {
    SchedulerView(todo: .constant(ToDo(title: "Sample")))
}
