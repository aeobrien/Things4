//
//  ContentView.swift
//  Things4
//
//  Created by Aidan O'Brien on 17/06/2025.
//

import SwiftUI
import Things4

struct ContentView: View {
    @EnvironmentObject var store: DatabaseStore
    @EnvironmentObject var selectionStore: SelectionStore
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var showingSettings = false

    var body: some View {
        Group {
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
        .onOpenURL { url in
            store.handleURL(url)
        }
    }

    private var splitView: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            detail
        }
    }

    private var stackView: some View {
        NavigationStack {
            sidebar
                .navigationDestination(for: ListSelection.self) { sel in
                    ToDoListView(selection: sel)
                }
        }
    }

    // MARK: – Sidebar
    private var sidebar: some View {
        List(selection: $selectionStore.selection) {
            defaultListsSection
            trashSection
            areasSection
        }
        .listStyle(.sidebar)
        .listRowSeparator(.hidden)
        .environment(\.defaultMinListRowHeight, 22)
        .background(Theme.sidebarBackground)
        #if os(macOS)
        .frame(minWidth: 220)
        .safeAreaInset(edge: .bottom) { bottomBar }
        #endif
    }

    // ───────────────────────── Helper chunks ─────────────────────────

    @ViewBuilder private var defaultListsSection: some View {
        Section {
            ForEach(DefaultList.allCases.filter { $0 != .trash }) { list in
                NavigationLink(value: ListSelection.list(list)) {
                    Label {
                        HStack {
                            Text(list.title)
                                .font(Theme.sidebarFont)
                            Spacer(minLength: 4)
                            let n = store.filteredToDos(selection: .list(list)).count
                            if n > 0 {
                                Text("\(n)")
                                    .font(Theme.countFont)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: iconForList(list))
                            .foregroundColor(Theme.sidebarIcon)
                    }
                }
                .listRowInsets(.init(top: Theme.rowVSpacing,
                                     leading: 6,
                                     bottom: Theme.rowVSpacing,
                                     trailing: 6))
            }
        }
    }

    @ViewBuilder private var trashSection: some View {
        Section {
            NavigationLink(value: ListSelection.list(.trash)) {
                Label("Trash", systemImage: "trash")
            }
        }
    }

    @ViewBuilder private var areasSection: some View {
        Section("Areas") {
            ForEach(store.database.areas) { area in
                areaRow(area)
                projectRows(in: area)
            }
        }
    }

    // MARK: – Row factories
    @ViewBuilder private func areaRow(_ area: Area) -> some View {
        NavigationLink(value: ListSelection.area(area.id)) {
            Text(area.title)
        }
        .contextMenu { Button("Delete", role: .destructive) {
            if let idx = store.database.areas.firstIndex(where: { $0.id == area.id }) {
                store.deleteAreas(at: IndexSet(integer: idx))
            }}}
    }

    @ViewBuilder private func projectRows(in area: Area) -> some View {
        let projects: [Project] = store.database.projects
            .filter { $0.parentAreaID == area.id }

        ForEach(projects) { project in
            NavigationLink(value: ListSelection.project(project.id)) {
                Label {
                    Text(project.title)
                } icon: {
                    ProgressView(value: store.progress(for: project.id))
                        .progressViewStyle(ThinRingStyle())
                }
            }
            .contextMenu {
                Button("Delete", role: .destructive) {
                    if let idx = projects.firstIndex(where: { $0.id == project.id }) {
                        store.deleteProjects(at: IndexSet(integer: idx),   // offsets
                                             in: area.id)                  // parent-area
                    }
                }
            }
        }
    }

    // MARK: – Bottom bar
    @ViewBuilder private var bottomBar: some View {
        HStack {
            Button(action: { store.addArea() }) {
                Label("New List", systemImage: "plus")
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.sidebarBackground)
    }

    private var detail: some View {
        Group {
            if let selection = selectionStore.selection {
                ToDoListView(selection: selection)
            } else {
                Text("Select a list")
                    .navigationTitle("Things4")
            }
        }
        .padding()
    }
    
    private func iconForList(_ list: DefaultList) -> String {
        switch list {
        case .inbox: return "tray"
        case .today: return "star"
        case .upcoming: return "calendar"
        case .anytime: return "tray.full"
        case .someday: return "archivebox"
        case .logbook: return "checkmark.circle"
        case .trash: return "trash"
        }
    }
    
    private func colorForList(_ list: DefaultList) -> Color {
        switch list {
        case .inbox: return .blue
        case .today: return .yellow
        case .upcoming: return .red
        case .anytime: return .teal
        case .someday: return .brown
        case .logbook: return .green
        case .trash: return .gray
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DatabaseStore())
        .environmentObject(SelectionStore())
}
