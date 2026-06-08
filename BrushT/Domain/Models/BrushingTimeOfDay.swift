import Foundation

enum BrushingTimeOfDay: String, CaseIterable, Codable, Identifiable, Hashable {
    case suggested
    case morning
    case afternoon
    case evening

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .suggested:
            return "По рекомендации"
        case .morning:
            return "Утро"
        case .afternoon:
            return "День"
        case .evening:
            return "Вечер"
        }
    }

    var systemImage: String {
        switch self {
        case .suggested:
            return "sparkles"
        case .morning:
            return "sunrise.fill"
        case .afternoon:
            return "sun.max.fill"
        case .evening:
            return "moon.stars.fill"
        }
    }
}
