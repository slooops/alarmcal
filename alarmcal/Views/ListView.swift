import SwiftData
import SwiftUI

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]

    @State private var showingEditor = false

    private let calendar = Calendar.current

    var body: some View {
        Group {
            if allEvents.isEmpty {
                ContentUnavailableView(
                    "No Events",
                    systemImage: "calendar",
                    description: Text("Tap + to create an event.")
                )
            } else {
                List {
                    ForEach(groupedEvents, id: \.date) { group in
                        Section {
                            ForEach(group.events, id: \.id) { event in
                                NavigationLink {
                                    EventDetailView(event: event)
                                } label: {
                                    EventRow(event: event)
                                }
                            }
                        } header: {
                            Text(sectionHeader(for: group.date))
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .sheet(isPresented: $showingEditor) {
            EventEditorView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private var groupedEvents: [EventGroup] {
        let grouped = Dictionary(grouping: allEvents) { event in
            calendar.startOfDay(for: event.startDate)
        }
        return grouped.map { EventGroup(date: $0.key, events: $0.value) }
            .sorted { $0.date < $1.date }
    }

    private func sectionHeader(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today — \(date.formatted(.dateTime.weekday(.wide).month().day()))"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow — \(date.formatted(.dateTime.weekday(.wide).month().day()))"
        } else {
            return date.formatted(.dateTime.weekday(.wide).month().day().year())
        }
    }
}

private struct EventGroup {
    let date: Date
    let events: [CalendarEvent]
}
