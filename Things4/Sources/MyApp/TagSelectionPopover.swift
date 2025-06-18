import SwiftUI
import Things4

struct TagSelectionPopover: View {
    @Binding var todo: ToDo
    @EnvironmentObject var store: DatabaseStore
    @Environment(\.dismiss) private var dismiss
    @State private var newTagName = ""
    @FocusState private var searchFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search/Add field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Add or search tags...", text: $newTagName)
                    .textFieldStyle(.plain)
                    .focused($searchFieldFocused)
                    .onSubmit {
                        addNewTag()
                    }
                if !newTagName.isEmpty {
                    Button(action: addNewTag) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            
            Divider()
            
            // Tag list
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(filteredTags()) { tag in
                        Button(action: { toggleTag(tag) }) {
                            HStack {
                                Image(systemName: todo.tagIDs.contains(tag.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.tagIDs.contains(tag.id) ? .accentColor : .secondary)
                                    .font(.system(size: 16))
                                Text(tag.name)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.1))
                                .opacity(todo.tagIDs.contains(tag.id) ? 1 : 0)
                        )
                    }
                    
                    if filteredTags().isEmpty && !newTagName.isEmpty {
                        Button(action: addNewTag) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.accentColor)
                                Text("Create \"\(newTagName)\"")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .frame(width: 300, height: 400)
        .onAppear {
            searchFieldFocused = true
        }
    }
    
    private func filteredTags() -> [Tag] {
        if newTagName.isEmpty {
            return store.database.tags.sorted { $0.name < $1.name }
        } else {
            return store.database.tags
                .filter { $0.name.localizedCaseInsensitiveContains(newTagName) }
                .sorted { $0.name < $1.name }
        }
    }
    
    private func toggleTag(_ tag: Tag) {
        if let index = todo.tagIDs.firstIndex(of: tag.id) {
            todo.tagIDs.remove(at: index)
        } else {
            todo.tagIDs.append(tag.id)
        }
    }
    
    private func addNewTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        // Check if tag already exists
        if let existingTag = store.database.tags.first(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            // Just add it if not already added
            if !todo.tagIDs.contains(existingTag.id) {
                todo.tagIDs.append(existingTag.id)
            }
        } else {
            // Create new tag
            let newTag = Tag(name: trimmed)
            store.database.tags.append(newTag)
            todo.tagIDs.append(newTag.id)
            store.save()
        }
        
        newTagName = ""
    }
}

#Preview {
    TagSelectionPopover(todo: .constant(ToDo(title: "Sample")))
        .environmentObject(DatabaseStore())
}