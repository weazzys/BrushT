import SwiftUI

struct NoteCardView: View {
    let record: BrushRecord
    var onDeleteNote: (() -> Void)?

    init(record: BrushRecord, onDeleteNote: (() -> Void)? = nil) {
        self.record = record
        self.onDeleteNote = onDeleteNote
    }

    var body: some View {
        AppFormCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Label(title, systemImage: iconName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.blue)

                    Spacer()

                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)

                    if let onDeleteNote {
                        Button(role: .destructive) {
                            onDeleteNote()
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption.weight(.semibold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(AppTheme.orange)
                        .accessibilityLabel("Удалить заметку")
                    }
                }

                Text(record.notes.isEmpty ? "Без заметки" : record.notes)
                    .font(.body)
                    .foregroundStyle(record.notes.isEmpty ? AppTheme.secondaryText : AppTheme.text)
                    .lineLimit(4)

                if record.isBrushing {
                    Text(DurationFormatter.shared.string(from: record.duration))
                        .font(.caption.weight(.medium))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
    }

    private var title: String {
        record.isStandaloneNote ? "Заметка" : record.timeOfDay.title
    }

    private var iconName: String {
        record.isStandaloneNote ? "note.text" : record.timeOfDay.systemImage
    }
}
