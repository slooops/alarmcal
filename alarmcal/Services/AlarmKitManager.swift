import AlarmKit
import SwiftUI

struct AlarmCalMetadata: AlarmMetadata {
    init() {}
}

@Observable
final class AlarmKitManager {
    static let shared = AlarmKitManager()

    var isAuthorized = false

    private static let snoozeDuration: Duration = .seconds(9 * 60)

    func requestAuthorization() async {
        do {
            let state = try await AlarmManager.shared.requestAuthorization()
            isAuthorized = state == .authorized
        } catch {
            isAuthorized = false
        }
    }

    func scheduleAlarm(for event: CalendarEvent) async throws {
        let fireDate = event.startDate.addingTimeInterval(-event.alarmLeadTime)

        let stopButton = AlarmButton(
            text: "Stop",
            textColor: .white,
            systemImageName: "checkmark.circle.fill"
        )
        let snoozeButton = AlarmButton(
            text: "Snooze",
            textColor: .white,
            systemImageName: "zzz"
        )
        let alert = AlarmAlert(
            title: LocalizedStringResource(stringLiteral: event.title),
            stopButton: stopButton,
            secondaryButton: snoozeButton,
            secondaryButtonBehavior: .countdown
        )
        let attributes = AlarmAttributes<AlarmCalMetadata>(
            presentation: AlarmPresentation(alert: alert),
            metadata: AlarmCalMetadata(),
            tintColor: .orange
        )
        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: Alarm.CountdownDuration(
                preAlert: nil,
                postAlert: Self.snoozeDuration
            ),
            schedule: .fixed(fireDate),
            attributes: attributes
        )

        let id = UUID()
        _ = try await AlarmManager.shared.schedule(
            id: id,
            configuration: configuration
        )
        event.alarmID = id
    }

    func cancelAlarm(for event: CalendarEvent) {
        guard let alarmID = event.alarmID else { return }
        try? AlarmManager.shared.cancel(id: alarmID)
        event.alarmID = nil
    }

    func syncAlarm(for event: CalendarEvent) async {
        cancelAlarm(for: event)
        if event.alarmEnabled {
            try? await scheduleAlarm(for: event)
        }
    }
}
