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
Things4/Sources/WatchApp/ComplicationController.swift
New
+30
-0

import ClockKit
import SwiftUI
import Things4

class ComplicationController: NSObject, CLKComplicationDataSource {
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptor = CLKComplicationDescriptor(identifier: "today_progress", displayName: "Today Progress", supportedFamilies: CLKComplicationFamily.allCases)
        handler([descriptor])
    }

    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {}

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        Task {
            let db = (try? await SyncManager.shared.load()) ?? Database()
            let engine = WorkflowEngine()
            let todos = engine.tasks(for: .today, in: db)
            let completed = todos.filter { $0.status == .completed }.count
            let progress = todos.isEmpty ? 0 : Double(completed) / Double(todos.count)
            let template = CLKComplicationTemplateGraphicCircularGaugeText()
            template.textProvider = CLKSimpleTextProvider(text: "\(Int(progress*100))%")
            template.gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .blue, fillFraction: progress)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        }
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        handler(nil)
    }
}