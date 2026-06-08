import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(preferencesStore: UserPreferencesStore = UserPreferencesStore()) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(preferencesStore: preferencesStore))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppSheetBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        dailyGoalCard
                        timerCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Настройки")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .appToolbarStyle()
        }
    }

    private var dailyGoalCard: some View {
        AppFormCard(title: "Чисток в день") {
            Picker("Чисток в день", selection: Binding(
                get: { viewModel.dailyGoalCount },
                set: { viewModel.updateDailyGoal($0) }
            )) {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
            }
            .appSegmentedPickerStyle()

            Text("Обычно рекомендуют две чистки в день: утром и вечером.")
                .font(.footnote)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var timerCard: some View {
        AppFormCard(title: "Длительность таймера") {
            Picker("Длительность", selection: Binding(
                get: { Int(viewModel.targetDuration) },
                set: { viewModel.updateTargetDuration(TimeInterval($0)) }
            )) {
                Text("1 мин").tag(60)
                Text("2 мин").tag(120)
                Text("3 мин").tag(180)
            }
            .appSegmentedPickerStyle()

            Text("Текущая цель: \(viewModel.targetDurationText).")
                .font(.footnote)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }
}
