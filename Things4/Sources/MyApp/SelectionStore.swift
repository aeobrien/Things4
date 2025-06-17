import SwiftUI

final class SelectionStore: ObservableObject {
    @Published var selection: ListSelection?
}
