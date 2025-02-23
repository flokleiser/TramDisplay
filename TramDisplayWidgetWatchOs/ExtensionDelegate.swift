import WatchKit
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if task is WKApplicationRefreshBackgroundTask {
                let complicationServer = CLKComplicationServer.sharedInstance()
                for complication in complicationServer.activeComplications ?? [] {
                    complicationServer.reloadTimeline(for: complication)
                }
            }
            task.setTaskCompletedWithSnapshot(false)
        }
    }
}
