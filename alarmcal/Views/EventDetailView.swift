import SwiftData
import SwiftUI

struct EventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: CalendarEvent

    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                Text(event.title)
                    .font(.title2.bold())
            }

            Section {
                if event.isAllDay {
                    LabeledContent("All Day") {
                        Text(event.startDate, format: .dateTime.weekday(.wide).month().day().year())
                    }
                } else {
                    LabeledContent("Starts") {
                        Text(event.startDate, format: .dateTime.month().day().year().hour().minute())
                    }
                    LabeledContent("Ends") {
                        Text(event.endDate, format: .dateTime.month().day().year().hour().minute())
                    }
                }
            }

            if !event.location.isEmpty {
                Section {
                    Label(event.location, systemImage: "location")
                }
            }

            if !event.notes.isEmpty {
                Section("Notes") {
                    Text(event.notes)
                }
            }

            Section {
                HStack {
                    Label("Alarm", systemImage: "alarm.fill")
                    Spacer()
                    if event.alarmEnabled {
                        let leadTime = LeadTime(rawValue: event.alarmLeadTime)
                        Text(leadTime?.label ?? "At time of event")
                            .foregroundStyle(.orange)
                    } else {
                        Text("Off")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button("Delete Event", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("Event")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditor = true
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            EventEditorView(event: event)
        }
        .confirmationDialog("Delete this event?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                AlarmKitManager.shared.cancelAlarm(for: event)
                modelContext.delete(event)
                dismiss()
            }
        }
    }
}
