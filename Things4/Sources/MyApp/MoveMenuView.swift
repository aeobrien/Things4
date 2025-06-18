import SwiftUI
import Things4

struct MoveMenuView: View {
    @EnvironmentObject var store: DatabaseStore
    let selectedTodos: [UUID]
    let onMove: (ListSelection) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Move to...")
                .font(.headline)
                .padding()
            
            Divider()
            
            List {
                Section("Lists") {
                    ForEach(DefaultList.allCases.filter { $0 != .trash && $0 != .logbook }) { list in
                        Button(action: {
                            onMove(.list(list))
                            dismiss()
                        }) {
                            Label(list.title, systemImage: iconForList(list))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section("Projects") {
                    ForEach(store.database.projects.filter { $0.status == .open }) { project in
                        Button(action: {
                            onMove(.project(project.id))
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                                Text(project.title)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section("Areas") {
                    ForEach(store.database.areas) { area in
                        Button(action: {
                            onMove(.area(area.id))
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                                Text(area.title)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .frame(width: 300, height: 400)
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
}

#Preview {
    MoveMenuView(selectedTodos: []) { _ in }
        .environmentObject(DatabaseStore())
}