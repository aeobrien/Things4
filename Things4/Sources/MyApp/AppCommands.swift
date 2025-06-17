import SwiftUI

struct AppCommands: Commands {
    @EnvironmentObject var store: DatabaseStore
    @EnvironmentObject var selectionStore: SelectionStore
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New To-Do") {
                let target = selectionStore.selection ?? .list(.inbox)
                store.addTodo(to: target)
            }
            .keyboardShortcut("n")

            Button("Complete To-Do") {
                store.toggleFirstTodo(in: selectionStore.selection)
            }
            .keyboardShortcut("k")

            Divider()

            Button("Quick Entry") {
                openWindow(id: "quickEntry")
            }
            .keyboardShortcut(.space, modifiers: [.control])
        }
    }
}
