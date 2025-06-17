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
