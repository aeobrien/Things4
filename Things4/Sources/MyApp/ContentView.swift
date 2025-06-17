import SwiftUI
import Things4

struct ContentView: View {
    @State private var selection: ListSelection?
    @StateObject private var store = DatabaseStore()

    var body: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            splitView
        } else {
            stackView
        }
        #else
        splitView
        #endif
    }

    private var splitView: some View {
        NavigationSplitView(selection: $selection) {
            sidebar
        } detail: {
            detail
        }
    }

    private var stackView: some View {
        NavigationStack(path: $selection) {
            sidebar
                .navigationDestination(for: ListSelection.self) { sel in
                    ToDoListView(store: store, selection: sel)
                }
        }
    }

    private var sidebar: some View {
        List(selection: $selection) {
            Section("Lists") {
                ForEach(DefaultList.allCases) { list in
                    NavigationLink(value: ListSelection.list(list)) {
                        Label(list.title, systemImage: "list.bullet")
                    }
                }
            }
            Section("Areas") {
                ForEach(store.database.areas) { area in
                    let areaProjects = store.database.projects.filter { $0.parentAreaID == area.id }
                    if areaProjects.isEmpty {
                        NavigationLink(value: ListSelection.area(area.id)) { Text(area.title) }
                    } else {
                        DisclosureGroup(area.title) {
                            ForEach(areaProjects) { project in
                                NavigationLink(value: ListSelection.project(project.id)) { Text(project.title) }
                            }
                        }
                    }
                }
            }
        }
    }

    private var detail: some View {
        if let selection {
            ToDoListView(store: store, selection: selection)
        } else {
            Text("Select a list")
                .navigationTitle("Things4")
        }
    }
}

#Preview {
    ContentView()
}
