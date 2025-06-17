//
//  Things4App.swift
//  Things4
//
//  Created by Aidan O'Brien on 17/06/2025.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct Things4App: App {
#if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif
    @StateObject private var store = DatabaseStore()
    @StateObject private var selectionStore = SelectionStore()
    @StateObject private var calendarManager = CalendarManager.shared
    @StateObject private var remindersImporter = RemindersImporter.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(selectionStore)
                .environmentObject(calendarManager)
                .environmentObject(remindersImporter)
        }
#if os(macOS)
        .commands { AppCommands().environmentObject(store).environmentObject(selectionStore) }
        WindowGroup(id: "quickEntry") { QuickEntryView() }
            .environmentObject(store)
            .environmentObject(selectionStore)
            .environmentObject(calendarManager)
            .environmentObject(remindersImporter)
#endif
    }
}

#if canImport(UIKit)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        NotificationCenter.default.post(name: .cloudKitDidChange, object: nil, userInfo: userInfo)
        return .newData
    }
}
#endif