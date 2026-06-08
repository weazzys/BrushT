import Foundation

final class UserPreferencesStore: ObservableObject {
    @Published private(set) var preferences: UserPreferences

    var dailyGoalCount: Int {
        preferences.dailyGoalCount
    }

    var targetDuration: TimeInterval {
        preferences.targetDuration
    }

    init() {
        self.preferences = Self.load()
    }

    func updateDailyGoal(_ goal: Int) {
        preferences.dailyGoalCount = goal
        save()
    }

    func updateTargetDuration(_ duration: TimeInterval) {
        preferences.targetDuration = duration
        save()
    }

    private static func load() -> UserPreferences {
        guard
            let data = UserDefaults.standard.data(forKey: "userPreferences"),
            let saved = try? JSONDecoder().decode(UserPreferences.self, from: data)
        else {
            return .default
        }

        return saved
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        UserDefaults.standard.set(data, forKey: "userPreferences")
    }
}
