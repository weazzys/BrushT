import Foundation

final class BrushDetailViewModel: ObservableObject {
    @Published private(set) var record: BrushRecord
    @Published var noteDraft: String

    private let brushStore: BrushRecordStore

    init(record: BrushRecord, brushStore: BrushRecordStore) {
        self.record = record
        self.noteDraft = record.notes
        self.brushStore = brushStore
    }

    var dateText: String {
        record.date.formatted(date: .complete, time: .shortened)
    }

    var durationText: String {
        DurationFormatter.shared.string(from: record.duration)
    }

    var reachedTarget: Bool {
        record.duration >= UserPreferences.default.targetDuration
    }

    var resultText: String {
        reachedTarget ? "Цель 2 минуты достигнута" : "Чистка короче 2 минут"
    }

    var noteText: String {
        record.notes.isEmpty ? "Заметка не добавлена" : record.notes
    }

    var hasNoteChanges: Bool {
        noteDraft.trimmingCharacters(in: .whitespacesAndNewlines) != record.notes
    }

    func saveNote() {
        let trimmedNote = noteDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        brushStore.update(record: record, notes: trimmedNote)
        record = BrushRecord(
            id: record.id,
            date: record.date,
            duration: record.duration,
            timeOfDay: record.timeOfDay,
            notes: trimmedNote,
            kind: record.kind
        )
        noteDraft = trimmedNote
    }

    func refresh(from records: [BrushRecord]) {
        guard let updatedRecord = records.first(where: { $0.id == record.id }) else { return }
        let hasLocalChanges = hasNoteChanges
        record = updatedRecord

        if !hasLocalChanges {
            noteDraft = updatedRecord.notes
        }
    }
}
