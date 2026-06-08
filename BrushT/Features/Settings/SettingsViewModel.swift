import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published private(set) var dailyGoalCount: Int
    @Published private(set) var targetDuration: TimeInterval

    private let preferencesStore: UserPreferencesStore
    private var cancellables = Set<AnyCancellable>()

    init(preferencesStore: UserPreferencesStore) {
        self.preferencesStore = preferencesStore
        self.dailyGoalCount = preferencesStore.dailyGoalCount
        self.targetDuration = preferencesStore.targetDuration

        preferencesStore.$preferences
            .sink { [weak self] preferences in
                self?.dailyGoalCount = preferences.dailyGoalCount
                self?.targetDuration = preferences.targetDuration
            }
            .store(in: &cancellables)
    }

    var targetDurationText: String {
        DurationFormatter.shared.string(from: targetDuration)
    }

    func updateDailyGoal(_ goal: Int) {
        preferencesStore.updateDailyGoal(goal)
    }

    func updateTargetDuration(_ duration: TimeInterval) {
        preferencesStore.updateTargetDuration(duration)
    }
}
