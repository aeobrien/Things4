//
//  ContentView.swift
//  Things4
//
//  Created by Aidan O'Brien on 17/06/2025.
//

import SwiftUI
import Things4

struct ContentView: View {
    @State private var selection: ListSelection?
    @StateObject private var store = DatabaseStore()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
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
                ForEach(Array(store.database.areas.enumerated()), id: \.element.id) { index, area in
                    let areaProjects = store.database.projects.filter { $0.parentAreaID == area.id }
                    if areaProjects.isEmpty {
                        NavigationLink(value: ListSelection.area(area.id)) { Text(area.title) }
                            .swipeActions { Button(role: .destructive) { store.deleteAreas(at: IndexSet(integer: index)) } label: { Label("Delete", systemImage: "trash") } }
                    } else {
                        DisclosureGroup(area.title) {
                            ForEach(Array(areaProjects.enumerated()), id: \.element.id) { pIndex, project in
                                NavigationLink(value: ListSelection.project(project.id)) {
                                    HStack {
                                        Text(project.title)
                                        Spacer()
                                        ProgressView(value: store.progress(for: project.id))
                                            .progressViewStyle(.circular)
                                    }
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteProjects(at: IndexSet(integer: pIndex), in: area.id)
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                            }
                            Button(action: { store.addProject(to: area.id) }) { Label("Add Project", systemImage: "plus") }
                        }
                        .swipeActions {
                            Button(role: .destructive) { store.deleteAreas(at: IndexSet(integer: index)) } label: { Label("Delete", systemImage: "trash") }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { store.addArea() }) { Image(systemName: "plus") }
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
        .padding()
    }
}

#Preview {
    ContentView()
}