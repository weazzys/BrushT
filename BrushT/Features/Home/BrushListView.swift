import SwiftUI

struct BrushListView: View {
    @StateObject private var recordStore: BrushRecordStore
    @StateObject private var preferencesStore: UserPreferencesStore
    @StateObject private var viewModel: BrushListViewModel
    @State private var selectedRecord: BrushRecord?
    @State private var isTimerPresented = false
    @State private var isSettingsPresented = false
    @State private var isNotesPresented = false
    @State private var isClearHistoryDialogPresented = false

    init(
        recordStore: BrushRecordStore = BrushRecordStore(),
        preferencesStore: UserPreferencesStore = UserPreferencesStore()
    ) {
        _recordStore = StateObject(wrappedValue: recordStore)
        _preferencesStore = StateObject(wrappedValue: preferencesStore)
        _viewModel = StateObject(wrappedValue: BrushListViewModel(
            recordStore: recordStore,
            preferencesStore: preferencesStore
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        progressCard

                        if viewModel.records.isEmpty {
                            emptyState
                        } else {
                            recordsSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        isNotesPresented = true
                    } label: {
                        Image(systemName: "note.text")
                    }
                    .accessibilityLabel("Заметки")

                    Button {
                        isSettingsPresented = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Настройки")

                    Menu {
                        Button(role: .destructive) {
                            isClearHistoryDialogPresented = true
                        } label: {
                            Label("Очистить историю", systemImage: "trash")
                        }
                        .disabled(viewModel.records.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Еще")
                }
            }
            .confirmationDialog(
                "Очистить всю историю?",
                isPresented: $isClearHistoryDialogPresented,
                titleVisibility: .visible
            ) {
                Button("Очистить историю", role: .destructive) {
                    viewModel.clearHistory()
                }

                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Все записи чистки и заметки будут удалены. Это действие нельзя отменить.")
            }
            .navigationDestination(item: $selectedRecord) { record in
                BrushDetailView(record: record, brushStore: recordStore)
            }
            .sheet(isPresented: $isTimerPresented, onDismiss: viewModel.refresh) {
                BrushTimerView(viewModel: BrushTimerViewModel(
                    brushStore: recordStore,
                    preferencesStore: preferencesStore
                ))
            }
            .sheet(isPresented: $isSettingsPresented, onDismiss: viewModel.refresh) {
                SettingsView(preferencesStore: preferencesStore)
            }
            .sheet(isPresented: $isNotesPresented, onDismiss: viewModel.refresh) {
                NavigationStack {
                    NotesJournalView(brushStore: recordStore)
                }
            }
            .onReceive(recordStore.$records) { _ in
                viewModel.refresh()
            }
            .onReceive(preferencesStore.$preferences) { _ in
                viewModel.refresh()
            }
            .appToolbarStyle()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Дневник")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.text)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Мой дневник чистки зубов")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 6)

            Button {
                isTimerPresented = true
            } label: {
                Label("Начать чистку", systemImage: "timer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AppPrimaryButtonStyle())
        }
    }

    private var progressCard: some View {
        AppFormCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    statPill(
                        icon: "flame.fill",
                        value: "\(viewModel.currentStreak)",
                        label: "дней серия",
                        tint: AppTheme.orange
                    )
                    statPill(
                        icon: "checkmark.circle.fill",
                        value: "\(viewModel.todayCount)/\(viewModel.dailyGoalCount)",
                        label: "сегодня",
                        tint: AppTheme.green
                    )
                    statPill(
                        icon: "clock.fill",
                        value: viewModel.targetDurationText,
                        label: "таймер",
                        tint: AppTheme.blue
                    )
                }

                ProgressView(value: viewModel.progressFraction)
                    .tint(viewModel.isGoalCompletedToday ? AppTheme.green : AppTheme.blue)

                Text(viewModel.progressText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }

    private func statPill(icon: String, value: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.text)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        AppFormCard {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(AppTheme.blue)
                Text("Записей пока нет")
                    .font(.headline)
                    .foregroundStyle(AppTheme.text)
                Text("Запустите таймер, а после завершения первая чистка появится здесь.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
        }
    }

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.text)

            LazyVStack(spacing: 12) {
                ForEach(viewModel.records) { record in
                    Button {
                        selectedRecord = record
                    } label: {
                        BrushCardView(record: record)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.delete(record: record)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}
