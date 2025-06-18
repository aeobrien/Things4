//
//  ToDoCardView.swift
//  Things4
//
import SwiftUI
import Things4

struct ThinRingStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle().stroke(.tertiary,   lineWidth: 2)
            Circle().trim(from: 0,
                          to: CGFloat(configuration.fractionCompleted ?? 0))
                   .stroke(Color.accentColor,
                           style: StrokeStyle(lineWidth: 2, lineCap: .round))
                   .rotationEffect(.degrees(-90))
        }
        .frame(width: 16, height: 16)
    }
}

struct ToDoCardView: View {
    @Binding var todo: ToDo
    let onExpand: () -> Void
    let isExpanded: Bool
    let toggleComplete: () -> Void
    @EnvironmentObject var store: DatabaseStore

    // MARK: body
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // row
            HStack(spacing: 10) {
                Button(action: toggleComplete) {
                    Image(systemName: todo.status == .completed
                          ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.status == .completed
                                         ? .accentColor : .secondary)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)

                Text(todo.title)
                    .font(Theme.taskFont)
                    .strikethrough(todo.status == .completed)
                    .foregroundColor(todo.status == .completed ? .secondary : .primary)
                    .animation(.easeInOut(duration: 0.1), value: todo.status)

                Spacer(minLength: 0)
            }

            if isExpanded { expandedBits }
        }
        .padding(isExpanded ? 12 : 0)
        .background(isExpanded ? Theme.cardBackground : Color.clear)
        .overlay(
            isExpanded ?
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.cardBorder) : nil
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: onExpand)
    }

    // MARK: – extra content when expanded
    @ViewBuilder private var expandedBits: some View {
        // Notes
        if !todo.notes.isEmpty {
            TextEditor(text: $todo.notes)
                .font(Theme.noteFont)
                .frame(minHeight: 60)
                .padding(6)
                .background(.quaternary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }

        // Tags
        if !todo.tagIDs.isEmpty {
            FlowLayout(spacing: 6) {
                ForEach(todo.tagIDs, id: \.self) { id in
                    if let tag = store.database.tags.first(where: { $0.id == id }) {
                        TagChip(tag: tag.name) { }
                            .font(Theme.tagFont)
                    }
                }
            }
        }

        // Dates
        HStack(spacing: 12) {
            if let start = todo.startDate {
                Label(start.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if let deadline = todo.deadline {
                Label(deadline.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}
