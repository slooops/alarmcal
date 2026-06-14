import SwiftData
import SwiftUI

struct EventEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let existingEvent: CalendarEvent?

    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var location: String
    @State private var notes: String
    @State private var alarmEnabled: Bool
    @State private var alarmLeadTime: Double

    var isEditing: Bool { existingEvent != nil }

    init(event: CalendarEvent) {
        self.existingEvent = event
        _title = State(initialValue: event.title)
        _startDate = State(initialValue: event.startDate)
        _endDate = State(initialValue: event.endDate)
        _isAllDay = State(initialValue: event.isAllDay)
        _location = State(initialValue: event.location)
        _notes = State(initialValue: event.notes)
        _alarmEnabled = State(initialValue: event.alarmEnabled)
        _alarmLeadTime = State(initialValue: event.alarmLeadTime)
    }

    init(initialDate: Date = .now) {
        self.existingEvent = nil
        let start = initialDate
        _title = State(initialValue: "")
        _startDate = State(initialValue: start)
        _endDate = State(initialValue: start.addingTimeInterval(3600))
        _isAllDay = State(initialValue: false)
        _location = State(initialValue: "")
        _notes = State(initialValue: "")
        _alarmEnabled = State(initialValue: false)
        _alarmLeadTime = State(initialValue: 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                }

                Section {
                    Toggle("All Day", isOn: $isAllDay)

                    if isAllDay {
                        DatePicker(
                            "Date",
                            selection: $startDate,
                            displayedComponents: .date
                        )
                    } else {
                        DatePicker(
                            "Starts",
                            selection: $startDate
                        )
                        DatePicker(
                            "Ends",
                            selection: $endDate
                        )
                    }
                }
                .onChange(of: startDate) { _, newValue in
                    if endDate <= newValue {
                        endDate = newValue.addingTimeInterval(3600)
                    }
                }

                Section {
                    Toggle(isOn: $alarmEnabled) {
                        Label("Alarm", systemImage: "alarm.fill")
                    }
                    .tint(.orange)

                    if alarmEnabled {
                        Picker("Alert", selection: $alarmLeadTime) {
                            ForEach(LeadTime.allCases) { option in
                                Text(option.label).tag(option.rawValue)
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "Edit Event" : "New Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let event: CalendarEvent
        if let existing = existingEvent {
            event = existing
        } else {
            event = CalendarEvent()
            modelContext.insert(event)
        }

        event.title = title.trimmingCharacters(in: .whitespaces)
        event.startDate = startDate
        event.endDate = isAllDay ? Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: startDate))! : endDate
        event.isAllDay = isAllDay
        event.location = location.trimmingCharacters(in: .whitespaces)
        event.notes = notes.trimmingCharacters(in: .whitespaces)
        event.alarmEnabled = alarmEnabled
        event.alarmLeadTime = alarmLeadTime

        Task {
            await AlarmKitManager.shared.syncAlarm(for: event)
        }

        dismiss()
    }
}
