import SwiftUI
import Things4

struct QuickEntryView: View {
    @EnvironmentObject var store: DatabaseStore
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var notes: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $title)
            TextField("Notes", text: $notes, axis: .vertical)
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Add") { addTask() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }

    @EnvironmentObject var selectionStore: SelectionStore

    private func addTask() {
        store.addQuickTodo(title: title, notes: notes, selection: selectionStore.selection)
        dismiss()
    }
}

#Preview {
    QuickEntryView()
        .environmentObject(DatabaseStore())
        .environmentObject(SelectionStore())
}
