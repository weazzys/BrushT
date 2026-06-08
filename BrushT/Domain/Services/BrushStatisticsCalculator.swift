import Foundation

enum BrushStatisticsCalculator {
    static func currentStreak(in records: [BrushRecord], dailyGoal: Int) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var day = calendar.startOfDay(for: Date())
        
        while true {
            let count = records.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            guard count >= dailyGoal else { break }
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }
        
        return streak
    }
}