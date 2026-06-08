import SwiftUI

struct BrushDetailView: View {
    @StateObject private var viewModel: BrushDetailViewModel
    @ObservedObject private var brushStore: BrushRecordStore
    @State private var isSaveConfirmationVisible = false

    init(record: BrushRecord, brushStore: BrushRecordStore) {
        self.brushStore = brushStore
        _viewModel = StateObject(wrappedValue: BrushDetailViewModel(
            record: record,
            brushStore: brushStore
        ))
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    summaryCard
                    detailsCard
                    notesCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Детали чистки")
        .onReceive(brushStore.$records) { records in
            viewModel.refresh(from: records)
        }
        .appToolbarStyle()
    }

    private var summaryCard: some View {
        AppFormCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.blue.opacity(0.12))
                    Image(systemName: viewModel.record.timeOfDay.systemImage)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(AppTheme.blue)
                }
                .frame(width: 62, height: 62)

                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.record.timeOfDay.title)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.text)
                    Text(viewModel.resultText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(viewModel.reachedTarget ? AppTheme.green : AppTheme.orange)
                }

                Spacer()
            }
        }
    }

    private var detailsCard: some View {
        AppFormCard(title: "Информация") {
            VStack(spacing: 0) {
                detailRow("Дата", viewModel.dateText, icon: "calendar")
                Divider()
                detailRow("Время дня", viewModel.record.timeOfDay.title, icon: "sun.max")
                Divider()
                detailRow("Длительность", viewModel.durationText, icon: "clock")
            }
        }
    }

    private var notesCard: some View {
        AppFormCard(title: "Заметка") {
            VStack(spacing: 12) {
                AppNotesEditor(
                    placeholder: "Добавьте заметку к этой чистке...",
                    text: $viewModel.noteDraft,
                    minHeight: 120
                )

                Button {
                    viewModel.saveNote()
                    showSaveConfirmation()
                } label: {
                    Label(
                        isSaveConfirmationVisible ? "Сохранено" : "Сохранить заметку",
                        systemImage: isSaveConfirmationVisible ? "checkmark.circle" : "checkmark.circle.fill"
                    )
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .disabled(!viewModel.hasNoteChanges)
                .opacity(viewModel.hasNoteChanges || isSaveConfirmationVisible ? 1 : 0.55)

                if isSaveConfirmationVisible {
                    Label("Заметка сохранена", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.32, dampingFraction: 0.78), value: isSaveConfirmationVisible)
        }
    }

    private func showSaveConfirmation() {
        withAnimation {
            isSaveConfirmationVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation {
                isSaveConfirmationVisible = false
            }
        }
    }

    private func detailRow(_ title: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.blue)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.text)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 12)
    }
}
