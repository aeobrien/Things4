import SwiftUI

final class SelectionStore: ObservableObject {
    @Published var selection: ListSelection?
    @Published var activeFilter: Filter = .all
}
