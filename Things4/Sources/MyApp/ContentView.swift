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

    private var sidebar: some View {
        List(selection: $selectionStore.selection) {
            Section {
                ForEach(DefaultList.allCases) { list in
                    NavigationLink(value: ListSelection.list(list)) {
                        Label {
                            HStack {
                                Text(list.title)
                                Spacer()
                                let count = store.filteredToDos(selection: .list(list)).count
                                if count > 0 {
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: iconForList(list))
                                .foregroundColor(colorForList(list))
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            Section {
                ForEach(Array(store.database.areas.enumerated()), id: \.element.id) { index, area in
                    let areaProjects = store.database.projects.filter { $0.parentAreaID == area.id }
                    if areaProjects.isEmpty {
                        NavigationLink(value: ListSelection.area(area.id)) { 
                            Label {
                                Text(area.title)
                            } icon: {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 8))
                            }
                        }
                        .swipeActions { Button(role: .destructive) { store.deleteAreas(at: IndexSet(integer: index)) } label: { Label("Delete", systemImage: "trash") } }
                    } else {
                        DisclosureGroup {
                            ForEach(Array(areaProjects.enumerated()), id: \.element.id) { pIndex, project in
                                NavigationLink(value: ListSelection.project(project.id)) {
                                    Label {
                                        HStack {
                                            Text(project.title)
                                            Spacer()
                                            ProgressView(value: store.progress(for: project.id))
                                                .progressViewStyle(.circular)
                                                .scaleEffect(0.8)
                                        }
                                    } icon: {
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 8))
                                    }
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteProjects(at: IndexSet(integer: pIndex), in: area.id)
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                            }
                            Button(action: { store.addProject(to: area.id) }) { 
                                Label("Add Project", systemImage: "plus.circle")
                                    .foregroundColor(.accentColor)
                            }
                        } label: {
                            Label {
                                Text(area.title)
                            } icon: {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 8))
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) { store.deleteAreas(at: IndexSet(integer: index)) } label: { Label("Delete", systemImage: "trash") }
                        }
                    }
                }
            }
            
            Section {
                Button(action: { store.addArea() }) {
                    Label("New List", systemImage: "plus")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.sidebar)
        #if os(macOS)
        .frame(minWidth: 220)
        #endif
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
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DatabaseStore())
        .environmentObject(SelectionStore())
}