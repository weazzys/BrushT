import Foundation
import Combine

final class BrushListViewModel: ObservableObject {
    @Published private(set) var records: [BrushRecord] = []
    @Published private(set) var todayCount: Int = 0
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var progressText: String = ""
    @Published private(set) var progressFraction: Double = 0

    private let recordStore: BrushRecordStore
    private let preferencesStore: UserPreferencesStore
    private let calendar: Calendar

    init(
        recordStore: BrushRecordStore,
        preferencesStore: UserPreferencesStore,
        calendar: Calendar = .current
    ) {
        self.recordStore = recordStore
        self.preferencesStore = preferencesStore
        self.calendar = calendar
        refresh()
    }

    var dailyGoalCount: Int {
        preferencesStore.dailyGoalCount
    }

    var targetDurationText: String {
        DurationFormatter.shared.string(from: preferencesStore.targetDuration)
    }

    var isGoalCompletedToday: Bool {
        todayCount >= dailyGoalCount
    }

    func refresh() {
        records = recordStore.records.filter(\.isBrushing)
        todayCount = countTodayRecords()
        currentStreak = BrushStatisticsCalculator.currentStreak(
            in: records,
            dailyGoal: dailyGoalCount
        )

        progressFraction = makeProgressFraction()
        progressText = makeProgressText()
    }

    func delete(record: BrushRecord) {
        recordStore.delete(record: record)
        refresh()
    }

    func clearHistory() {
        recordStore.deleteAll()
        refresh()
    }

    private func countTodayRecords() -> Int {
        records.filter { calendar.isDateInToday($0.date) }.count
    }

    private func makeProgressFraction() -> Double {
        guard dailyGoalCount > 0 else { return 0 }
        return min(1, Double(todayCount) / Double(dailyGoalCount))
    }

    private func makeProgressText() -> String {
        let remaining = max(0, dailyGoalCount - todayCount)
        return remaining == 0 ? "План на сегодня выполнен" : "Осталось чисток: \(remaining)"
    }
}
