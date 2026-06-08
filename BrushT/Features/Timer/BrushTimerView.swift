import SwiftUI

struct BrushTimerView: View {
    @StateObject private var viewModel: BrushTimerViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: BrushTimerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppSheetBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        statusCard
                        timerCard
                        timeOfDayPicker
                        notesCard
                        todayCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 110)
                }
            }
            .navigationTitle("Таймер чистки")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                controls
            }
            .appToolbarStyle()
        }
    }

    private var statusCard: some View {
        AppFormCard {
            HStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundStyle(AppTheme.blue)
                    .frame(width: 34)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.phaseTitle)
                        .font(.headline)
                        .foregroundStyle(AppTheme.text)
                    Text(viewModel.motivationMessage)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()
            }
        }
    }

    private var timerCard: some View {
        AppFormCard {
            VStack(spacing: 18) {
                ZStack {
                    TimerRingView(progress: viewModel.progress, elapsed: viewModel.elapsed)
                        .frame(width: 238, height: 238)

                    VStack(spacing: 6) {
                        Text(viewModel.primaryTimeText)
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.text)
                            .monospacedDigit()

                        Text(viewModel.phase == .finished ? "запишите результат" : "до цели")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 0) {
                    timerStat(title: "Прошло", value: viewModel.elapsedText)
                    Divider()
                    timerStat(title: "Осталось", value: viewModel.remainingText)
                    Divider()
                    timerStat(title: "Цель", value: viewModel.targetText)
                }
                .frame(height: 54)
            }
        }
    }

    private func timerStat(title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.text)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }

    private var timeOfDayPicker: some View {
        AppFormCard(title: "Время дня") {
            Picker("Время дня", selection: $viewModel.timeOfDay) {
                ForEach(BrushingTimeOfDay.allCases) { timeOfDay in
                    Text(timeOfDay.title).tag(timeOfDay)
                }
            }
            .appSegmentedPickerStyle()
            .disabled(viewModel.phase == .running)
        }
    }

    private var notesCard: some View {
        AppFormCard(title: "Заметка") {
            AppNotesEditor(
                placeholder: "Ощущения, паста, рекомендация врача...",
                text: $viewModel.notes,
                minHeight: 96
            )
        }
    }

    private var todayCard: some View {
        AppFormCard(title: "Сегодня") {
            if viewModel.todayRecords.isEmpty {
                Text("Пока нет сохраненных чисток за сегодня.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.todayRecords.prefix(3)) { record in
                        HStack {
                            Label(record.timeOfDay.title, systemImage: record.timeOfDay.systemImage)
                            Spacer()
                            Text(DurationFormatter.shared.string(from: record.duration))
                                .monospacedDigit()
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.text)
                    }
                }
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            switch viewModel.phase {
            case .idle:
                Button {
                    viewModel.start()
                } label: {
                    Label("Старт", systemImage: "play.fill")
                }
                .buttonStyle(AppPrimaryButtonStyle())

            case .running:
                Button {
                    viewModel.pause()
                } label: {
                    Label("Пауза", systemImage: "pause.fill")
                }
                .buttonStyle(AppPanelSecondaryButtonStyle())

                Button {
                    viewModel.finishAndSave()
                    dismiss()
                } label: {
                    Label("Готово", systemImage: "checkmark")
                }
                .buttonStyle(AppPrimaryButtonStyle())

            case .paused:
                Button {
                    viewModel.start()
                } label: {
                    Label("Продолжить", systemImage: "play.fill")
                }
                .buttonStyle(AppPanelSecondaryButtonStyle())

                Button {
                    viewModel.finishAndSave()
                    dismiss()
                } label: {
                    Label("Сохранить", systemImage: "checkmark")
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .disabled(!viewModel.canSave)

            case .finished:
                Button {
                    viewModel.finishAndSave()
                    dismiss()
                } label: {
                    Label("Сохранить", systemImage: "checkmark")
                }
                .buttonStyle(AppPrimaryButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(.regularMaterial)
    }
}
