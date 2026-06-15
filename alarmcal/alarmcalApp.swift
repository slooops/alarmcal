import SwiftData
import SwiftUI

@main
struct alarmcalApp: App {
    var body: some Scene {
        WindowGroup {
            CalendarRootView()
                .task {
                    await AlarmKitManager.shared.requestAuthorization()
                }
        }
        .modelContainer(for: CalendarEvent.self)
    }
}
