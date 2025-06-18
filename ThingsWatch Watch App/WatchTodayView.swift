import SwiftUI

struct WatchTodayView: View {
    @EnvironmentObject var store: WatchStore

    var body: some View {
        List {
            ForEach(store.todosToday()) { todo in
                Button(action: { store.toggle(todo) }) {
                    HStack {
                        Image(systemName: todo.status == .completed ? "checkmark.circle.fill" : "circle")
                        Text(todo.title)
                    }
                }
            }
        }
    }
}

struct WatchTodayView_Previews: PreviewProvider {
    static var previews: some View {
        WatchTodayView().environmentObject(WatchStore())
    }
}
