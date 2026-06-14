import Foundation
import SwiftData

@Model
final class CalendarEvent {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var location: String
    var notes: String
    var alarmEnabled: Bool
    var alarmLeadTime: TimeInterval
    var alarmID: UUID?

    init(
        title: String = "",
        startDate: Date = .now,
        endDate: Date = .now.addingTimeInterval(3600),
        isAllDay: Bool = false,
        location: String = "",
        notes: String = "",
        alarmEnabled: Bool = false,
        alarmLeadTime: TimeInterval = 0,
        alarmID: UUID? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.notes = notes
        self.alarmEnabled = alarmEnabled
        self.alarmLeadTime = alarmLeadTime
        self.alarmID = alarmID
    }
}
