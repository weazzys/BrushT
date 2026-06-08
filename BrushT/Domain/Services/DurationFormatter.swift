import Foundation

final class DurationFormatter {
    static let shared = DurationFormatter()

    private init() {}

    func string(from duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
