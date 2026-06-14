import Foundation

enum LeadTime: Double, CaseIterable, Identifiable {
    case atTime = 0
    case oneMin = 60
    case fiveMin = 300
    case fifteenMin = 900
    case thirtyMin = 1800
    case oneHour = 3600
    case twoHours = 7200

    var id: Double { rawValue }

    var label: String {
        switch self {
        case .atTime: "At time of event"
        case .oneMin: "1 minute before"
        case .fiveMin: "5 minutes before"
        case .fifteenMin: "15 minutes before"
        case .thirtyMin: "30 minutes before"
        case .oneHour: "1 hour before"
        case .twoHours: "2 hours before"
        }
    }
}
