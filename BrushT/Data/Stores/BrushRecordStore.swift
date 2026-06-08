import Foundation

final class BrushRecordStore: ObservableObject {
    @Published private(set) var records: [BrushRecord] = []

    init() {
        loadRecords()
    }

    func loadRecords() {
        guard
            let data = UserDefaults.standard.data(forKey: "brushRecords"),
            let decoded = try? JSONDecoder().decode([BrushRecord].self, from: data)
        else {
            records = []
            return
        }

        records = decoded.sorted { $0.date > $1.date }
    }

    func add(duration: TimeInterval, timeOfDay: BrushingTimeOfDay, notes: String) {
        let newRecord = BrushRecord(
            id: UUID(),
            date: Date(),
            duration: duration,
            timeOfDay: timeOfDay,
            notes: notes
        )
        records.insert(newRecord, at: 0)
        save()
    }

    func addNote(_ notes: String) {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNotes.isEmpty else { return }

        let newRecord = BrushRecord(
            id: UUID(),
            date: Date(),
            duration: 0,
            timeOfDay: .evening,
            notes: trimmedNotes,
            kind: .note
        )
        records.insert(newRecord, at: 0)
        save()
    }

    func delete(record: BrushRecord) {
        records.removeAll { $0.id == record.id }
        save()
    }

    func deleteAll() {
        records.removeAll()
        save()
    }

    func update(record: BrushRecord, notes: String) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index] = BrushRecord(
            id: record.id,
            date: record.date,
            duration: record.duration,
            timeOfDay: record.timeOfDay,
            notes: notes,
            kind: record.kind
        )
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: "brushRecords")
    }
}
