import Foundation
import Combine

final class NotesJournalViewModel: ObservableObject {
    @Published private(set) var noteRecords: [BrushRecord]
    @Published var newNoteText = ""

    private let brushStore: BrushRecordStore

    init(brushStore: BrushRecordStore) {
        self.brushStore = brushStore
        self.noteRecords = []
        refresh()
    }

    var isEmpty: Bool {
        noteRecords.isEmpty
    }

    var canSaveNote: Bool {
        !newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func refresh() {
        noteRecords = brushStore.records
            .filter { !$0.notes.isEmpty }
            .sorted { $0.date > $1.date }
    }

    func addNote() {
        brushStore.addNote(newNoteText)
        newNoteText = ""
        refresh()
    }

    func deleteNote(from record: BrushRecord) {
        if record.isStandaloneNote {
            brushStore.delete(record: record)
        } else {
            brushStore.update(record: record, notes: "")
        }
        refresh()
    }
}
