import SwiftUI
import Things4

struct ToDoDetailView: View {
    @EnvironmentObject var store: DatabaseStore
    @Binding var todo: ToDo
    @State private var newChecklistTitle = ""
    @State private var newTagName = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Title", text: $todo.title)
                        .font(.title2)
                        .textFieldStyle(.plain)
                        .onChange(of: todo.title) { _ in store.save() }
                }
                .padding(.horizontal)
                
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("NOTES")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $todo.notes)
                        .font(.body)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .onChange(of: todo.notes) { _ in store.save() }
                }
                .padding(.horizontal)
                
                // Tags
                VStack(alignment: .leading, spacing: 8) {
                    Text("TAGS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(todo.tagIDs, id: \.self) { tagID in
                            if let tag = store.database.tags.first(where: { $0.id == tagID }) {
                                TagChip(tag: tag.name) {
                                    if let index = todo.tagIDs.firstIndex(of: tagID) {
                                        todo.tagIDs.remove(at: index)
                                        store.save()
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 4) {
                            TextField("Add tag", text: $newTagName)
                                .textFieldStyle(.plain)
                                .frame(width: 100)
                                .onSubmit { addTag() }
                            Button(action: addTag) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                            .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                .padding(.horizontal)
                
                // When
                VStack(alignment: .leading, spacing: 12) {
                    Text("WHEN")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Start Date", isOn: Binding(get: {
                            todo.startDate != nil
                        }, set: { value in
                            if value {
                                todo.startDate = Date()
                            } else {
                                todo.startDate = nil
                            }
                            store.save()
                        }))
                        
                        if let startDate = todo.startDate {
                            DatePicker("", selection: Binding(get: {
                                startDate
                            }, set: { date in
                                todo.startDate = date
                                store.save()
                            }), displayedComponents: .date)
                            .datePickerStyle(.compact)
                        }
                        
                        Toggle("Deadline", isOn: Binding(get: {
                            todo.deadline != nil
                        }, set: { value in
                            if value {
                                todo.deadline = Date()
                            } else {
                                todo.deadline = nil
                            }
                            store.save()
                        }))
                        
                        if let deadline = todo.deadline {
                            DatePicker("", selection: Binding(get: {
                                deadline
                            }, set: { date in
                                todo.deadline = date
                                store.save()
                            }), displayedComponents: .date)
                            .datePickerStyle(.compact)
                        }
                    }
                    .padding(.leading)
                }
                .padding(.horizontal)
                
                // Checklist
                if !todo.checklist.isEmpty || !newChecklistTitle.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CHECKLIST")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            ForEach($todo.checklist) { $item in
                                HStack(spacing: 12) {
                                    Button(action: {
                                        item.isCompleted.toggle()
                                        store.save()
                                    }) {
                                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isCompleted ? .accentColor : .secondary)
                                            .font(.system(size: 20))
                                    }
                                    .buttonStyle(.plain)
                                    
                                    TextField("Item", text: $item.title)
                                        .textFieldStyle(.plain)
                                        .onChange(of: item.title) { _ in store.save() }
                                }
                            }
                            .onDelete { indexSet in
                                todo.checklist.remove(atOffsets: indexSet)
                                store.save()
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 20))
                                    .opacity(0.3)
                                
                                TextField("Add checklist item", text: $newChecklistTitle)
                                    .textFieldStyle(.plain)
                                    .onSubmit { addChecklistItem() }
                            }
                        }
                        .padding(.leading)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .frame(minWidth: 400, idealWidth: 600)
        .navigationTitle("Edit To-Do")
        .toolbar { 
            #if os(macOS)
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    dismiss()
                }
            }
            #else
            EditButton()
            #endif
        }
    }

    private func addChecklistItem() {
        let trimmed = newChecklistTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        todo.checklist.append(ChecklistItem(title: trimmed, isCompleted: false))
        store.save()
        newChecklistTitle = ""
    }
    
    private func addTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        // Check if tag already exists in database
        if let existingTag = store.database.tags.first(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            // Add existing tag if not already added
            if !todo.tagIDs.contains(existingTag.id) {
                todo.tagIDs.append(existingTag.id)
                store.save()
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

struct TagChip: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(for: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(for: proposal, subviews: subviews)
        for (subview, position) in zip(subviews, result.positions) {
            subview.place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func layout(for proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > (proposal.width ?? .infinity) && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }
        
        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

#Preview {
    ToDoDetailView(todo: .constant(ToDo(title: "Sample")))
        .environmentObject(DatabaseStore())
}