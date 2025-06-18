import SwiftUI
import Things4

struct TodoInfoView: View {
    let todo: ToDo
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Info")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Info grid
            VStack(alignment: .leading, spacing: 16) {
                // Created
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(dateFormatter.string(from: todo.creationDate))
                        .font(.body)
                }
                
                // Modified
                VStack(alignment: .leading, spacing: 4) {
                    Text("Modified")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(dateFormatter.string(from: todo.modificationDate))
                        .font(.body)
                }
                
                // Completed (if applicable)
                if let completionDate = todo.completionDate {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(dateFormatter.string(from: completionDate))
                            .font(.body)
                    }
                }
                
                // Status
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(todo.status.rawValue.capitalized)
                        .font(.body)
                }
                
                // ID (for debugging/support)
                VStack(alignment: .leading, spacing: 4) {
                    Text("ID")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(todo.id.uuidString)
                        .font(.caption)
                        .textSelection(.enabled)
                }
            }
            .frame(minWidth: 300, alignment: .leading)
            
            Spacer()
            
            // OK button
            Button("OK") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

#Preview {
    TodoInfoView(todo: ToDo(title: "Sample Todo"))
}