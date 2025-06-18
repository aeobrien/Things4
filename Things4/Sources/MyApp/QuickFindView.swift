import SwiftUI
import Things4

struct QuickFindView: View {
    @EnvironmentObject var store: DatabaseStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @FocusState private var searchFieldFocused: Bool
    
    var searchResults: [ToDo] {
        guard !searchText.isEmpty else { return [] }
        let lowercasedSearch = searchText.lowercased()
        return store.database.toDos.filter { todo in
            todo.title.lowercased().contains(lowercasedSearch) ||
            todo.notes.lowercased().contains(lowercasedSearch) ||
            todo.tagIDs.contains { tagID in
                store.database.tags.first { $0.id == tagID }?.name.lowercased().contains(lowercasedSearch) ?? false
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search todos...", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($searchFieldFocused)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Results
            if searchText.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Start typing to search")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchResults.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No results for \"\(searchText)\"")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(searchResults) { todo in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title)
                            .font(.system(size: 14))
                            .foregroundColor(todo.status == .completed ? .secondary : .primary)
                            .strikethrough(todo.status == .completed)
                        
                        if !todo.notes.isEmpty {
                            Text(todo.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        HStack {
                            // Location
                            if let projectID = todo.parentProjectID,
                               let project = store.database.projects.first(where: { $0.id == projectID }) {
                                Label(project.title, systemImage: "circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else if let areaID = todo.parentAreaID,
                                      let area = store.database.areas.first(where: { $0.id == areaID }) {
                                Label(area.title, systemImage: "circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                // Show which default list it would appear in
                                let list = store.filteredToDos(selection: .list(.inbox)).contains(todo) ? "Inbox" :
                                           store.filteredToDos(selection: .list(.today)).contains(todo) ? "Today" :
                                           store.filteredToDos(selection: .list(.upcoming)).contains(todo) ? "Upcoming" :
                                           store.filteredToDos(selection: .list(.anytime)).contains(todo) ? "Anytime" :
                                           store.filteredToDos(selection: .list(.someday)).contains(todo) ? "Someday" :
                                           todo.status == .completed ? "Logbook" :
                                           todo.status == .canceled ? "Trash" : ""
                                if !list.isEmpty {
                                    Text(list)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Tags
                            if !todo.tagIDs.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(todo.tagIDs, id: \.self) { tagID in
                                        if let tag = store.database.tags.first(where: { $0.id == tagID }) {
                                            Text(tag.name)
                                                .font(.caption2)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.secondary.opacity(0.1))
                                                .cornerRadius(3)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 600, height: 400)
        .onAppear {
            searchFieldFocused = true
        }
    }
}

#Preview {
    QuickFindView()
        .environmentObject(DatabaseStore())
}