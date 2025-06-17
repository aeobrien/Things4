import SwiftUI
import Things4

struct ContentView: View {
    @State private var selection: String?
    @State private var database = SampleData.database

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
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
    }

    private var stackView: some View {
        NavigationStack {
            sidebar
                .navigationDestination(for: String.self) { title in
                    Text(title)
                        .navigationTitle(title)
                }
        }
    }

    private var sidebar: some View {
        List(selection: $selection) {
            Section("Lists") {
                ForEach(DefaultList.allCases) { list in
                    NavigationLink(value: list.title) {
                        Label(list.title, systemImage: "list.bullet")
                    }
                }
            }
            Section("Areas") {
                ForEach(database.areas) { area in
                    let areaProjects = database.projects.filter { $0.parentAreaID == area.id }
                    if areaProjects.isEmpty {
                        NavigationLink(value: area.title) { Text(area.title) }
                    } else {
                        DisclosureGroup(area.title) {
                            ForEach(areaProjects) { project in
                                NavigationLink(value: project.title) { Text(project.title) }
                            }
                        }
                    }
                }
            }
        }
    }

    private var detail: some View {
        if let selection {
            Text(selection)
                .navigationTitle(selection)
        } else {
            Text("Select a list")
                .navigationTitle("Things4")
        }
    }
}

#Preview {
    ContentView()
}
