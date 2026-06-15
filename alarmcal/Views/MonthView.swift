import SwiftData
import SwiftUI

struct MonthView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()
    @State private var showingEditor = false

    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            monthHeader
            weekdayHeader
            monthGrid
            Divider()
            dayEventsList
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Today") {
                    withAnimation {
                        displayedMonth = Date()
                        selectedDate = Date()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            EventEditorView(initialDate: selectedDate)
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation {
                    displayedMonth = calendar.date(
                        byAdding: .month, value: -1, to: displayedMonth
                    )!
                }
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.title2.bold())

            Spacer()

            Button {
                withAnimation {
                    displayedMonth = calendar.date(
                        byAdding: .month, value: 1, to: displayedMonth
                    )!
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }

    private var monthGrid: some View {
        let days = daysInMonth()
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(for: date)
                } else {
                    Text("")
                        .frame(height: 36)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private func dayCell(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasEvents = eventsForDay(date).count > 0

        return Button {
            withAnimation { selectedDate = date }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : isToday ? .accentColor : .primary)
                    .frame(width: 32, height: 32)
                    .background {
                        if isSelected {
                            Circle().fill(.accent)
                        } else if isToday {
                            Circle().strokeBorder(.accent, lineWidth: 1.5)
                        }
                    }

                Circle()
                    .fill(isSelected ? .accent : .secondary)
                    .frame(width: 4, height: 4)
                    .opacity(hasEvents ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
    }

    private var dayEventsList: some View {
        let events = eventsForDay(selectedDate)
        return Group {
            HStack {
                Text(selectedDate, format: .dateTime.weekday(.wide).month().day())
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if events.isEmpty {
                ContentUnavailableView(
                    "No Events",
                    systemImage: "calendar",
                    description: Text("Tap + to create an event.")
                )
            } else {
                List {
                    ForEach(events, id: \.id) { event in
                        NavigationLink {
                            EventDetailView(event: event)
                        } label: {
                            EventRow(event: event)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func eventsForDay(_ date: Date) -> [CalendarEvent] {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return allEvents.filter { event in
            event.startDate < end && event.endDate > start
        }
    }

    private func daysInMonth() -> [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        let firstOfMonth = calendar.date(from: comps)!
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth))
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }
}

struct EventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.alarmEnabled ? .orange : .accent)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.body)
                    .lineLimit(1)

                if event.isAllDay {
                    Text("All Day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(
                        "\(event.startDate, format: .dateTime.hour().minute()) – \(event.endDate, format: .dateTime.hour().minute())"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if event.alarmEnabled {
                Image(systemName: "alarm.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}
