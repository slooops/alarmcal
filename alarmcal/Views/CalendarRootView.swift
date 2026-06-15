import SwiftUI

enum CalendarViewMode: String, CaseIterable {
    case month = "Month"
    case list = "List"

    var systemImage: String {
        switch self {
        case .month: "calendar"
        case .list: "list.bullet"
        }
    }
}

struct CalendarRootView: View {
    @State private var viewMode: CalendarViewMode = .month

    var body: some View {
        NavigationStack {
            Group {
                switch viewMode {
                case .month:
                    MonthView()
                case .list:
                    ListView()
                }
            }
            .navigationTitle(viewMode == .month ? "Calendar" : "Events")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Picker("View", selection: $viewMode) {
                        ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode.systemImage)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}
