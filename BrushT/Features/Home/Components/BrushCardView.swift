import SwiftUI

struct BrushCardView: View {
    let record: BrushRecord

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.blue.opacity(0.12))
                Image(systemName: record.timeOfDay.systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.blue)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 5) {
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.text)

                HStack(spacing: 8) {
                    Label(record.timeOfDay.title, systemImage: "calendar")
                    Text("•")
                    Text(DurationFormatter.shared.string(from: record.duration))
                        .monospacedDigit()
                }
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)

                if !record.notes.isEmpty {
                    Text(record.notes)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.border, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 3)
    }
}
