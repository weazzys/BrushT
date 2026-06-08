import Foundation

struct UserPreferences: Codable, Equatable {
    var targetDuration: TimeInterval
    var dailyGoalCount: Int

    static let `default` = UserPreferences(
        targetDuration: 120,
        dailyGoalCount: 2
    )
}
