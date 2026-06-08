import Foundation
import Combine

final class BrushTimerViewModel: ObservableObject {
    enum TimerPhase {
        case idle
        case running
        case paused
        case finished
    }

    @Published var elapsed: TimeInterval = 0
    @Published var notes: String = ""
    @Published var phase: TimerPhase = .idle
    @Published var timeOfDay: BrushingTimeOfDay = .suggested

    private let brushStore: BrushRecordStore
    private let preferencesStore: UserPreferencesStore
    private var timer: Timer?

    init(brushStore: BrushRecordStore, preferencesStore: UserPreferencesStore) {
        self.brushStore = brushStore
        self.preferencesStore = preferencesStore
    }

    deinit {
        timer?.invalidate()
    }

    var targetDuration: TimeInterval {
        preferencesStore.targetDuration
    }

    var progress: Double {
        guard targetDuration > 0 else { return 0 }
        return min(1, max(0, elapsed / targetDuration))
    }

    var elapsedText: String {
        DurationFormatter.shared.string(from: elapsed)
    }

    var remainingText: String {
        DurationFormatter.shared.string(from: max(0, targetDuration - elapsed))
    }

    var targetText: String {
        DurationFormatter.shared.string(from: targetDuration)
    }

    var primaryTimeText: String {
        phase == .finished ? elapsedText : remainingText
    }

    var phaseTitle: String {
        switch phase {
        case .idle:
            return "Готовы начать"
        case .running:
            return "Идет чистка"
        case .paused:
            return "Пауза"
        case .finished:
            return "Цель достигнута"
        }
    }

    var todayCount: Int {
        brushStore.records.filter { Calendar.current.isDateInToday($0.date) }.count
    }

    var remainingTodayCount: Int {
        max(0, preferencesStore.dailyGoalCount - todayCount)
    }

    var motivationMessage: String {
        if remainingTodayCount == 0 {
            return "План на сегодня уже выполнен. Эта запись пойдет в историю."
        }
        return "До дневной цели осталось: \(remainingTodayCount)"
    }

    var canSave: Bool {
        elapsed >= 1
    }

    var currentTip: String {
        Self.brushingTips[Calendar.current.component(.day, from: Date()) % Self.brushingTips.count]
    }

    var todayRecords: [BrushRecord] {
        brushStore.records.filter { Calendar.current.isDateInToday($0.date) }
    }

    func start() {
        guard phase != .running else { return }
        phase = .running
        startTicker()
    }

    func togglePause() {
        phase == .running ? pause() : start()
    }

    func pause() {
        guard phase == .running else { return }
        phase = .paused
        stopTicker()
    }

    func reset() {
        stopTicker()
        elapsed = 0
        notes = ""
        phase = .idle
    }

    func finishAndSave() {
        stopTicker()
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        brushStore.add(
            duration: max(elapsed, 1),
            timeOfDay: timeOfDay,
            notes: trimmedNotes
        )
        phase = .finished
    }

    private func startTicker() {
        stopTicker()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self, self.phase == .running else { return }
            self.elapsed += 0.2
            if self.elapsed >= self.targetDuration {
                self.elapsed = self.targetDuration
                self.phase = .finished
                self.stopTicker()
            }
        }
    }

    private func stopTicker() {
        timer?.invalidate()
        timer = nil
    }

    static let brushingTips: [String] = [
        "Держите щетку под углом 45 градусов к линии десен.",
        "Чистите внешние, внутренние и жевательные поверхности зубов.",
        "Не давите слишком сильно: мягкие круговые движения эффективнее.",
        "Не забывайте про язык и линию десен.",
        "После чистки промойте щетку и поставьте ее сушиться вертикально."
    ]
}
