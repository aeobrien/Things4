import SwiftUI

@main
struct ThingsWatchApp: App {
    @StateObject private var store = WatchStore()
    var body: some Scene {
        WindowGroup {
            WatchTodayView()
                .environmentObject(store)
        }
    }
}
