import SwiftUI
import UIKit

enum AppTheme {
    static let background = Color(red: 0.93, green: 0.98, blue: 0.94)
    static let surface = Color.white
    static let surfaceMuted = Color(red: 0.88, green: 0.96, blue: 0.91)
    static let text = Color(red: 0.06, green: 0.14, blue: 0.11)
    static let secondaryText = Color(red: 0.36, green: 0.47, blue: 0.42)
    static let border = Color(red: 0.75, green: 0.88, blue: 0.79)
    static let blue = Color(red: 0.08, green: 0.46, blue: 0.88)
    static let teal = Color(red: 0.00, green: 0.62, blue: 0.66)
    static let green = Color(red: 0.05, green: 0.58, blue: 0.36)
    static let orange = Color(red: 0.92, green: 0.46, blue: 0.05)
}

enum AppAppearance {
    static func configure() {
        configureNavigationBar()
        configureSegmentedControls()
    }

    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.background)
        appearance.shadowColor = UIColor(AppTheme.border.opacity(0.45))
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.text),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.text),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    private static func configureSegmentedControls() {
        let control = UISegmentedControl.appearance()
        control.backgroundColor = UIColor(AppTheme.surfaceMuted)
        control.selectedSegmentTintColor = UIColor(AppTheme.blue)
        control.setTitleTextAttributes(
            [
                .foregroundColor: UIColor(AppTheme.secondaryText),
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
            ],
            for: .normal
        )
        control.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 15, weight: .bold)
            ],
            for: .selected
        )
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppTheme.background,
                Color(red: 0.89, green: 0.96, blue: 0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct AppSheetBackground: View {
    var body: some View {
        AppBackground()
    }
}

struct AppFormCard<Content: View>: View {
    private let title: String?
    private let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    init(title: String? = nil, content: AnyView) where Content == AnyView {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.text)
            }

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.border, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 12, y: 4)
    }
}

struct AppNotesEditor: View {
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.70))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
            }

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .foregroundStyle(AppTheme.text)
                .frame(minHeight: minHeight)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
        }
        .background(AppTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.border, lineWidth: 1)
        }
    }
}

struct AppPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                LinearGradient(
                    colors: [AppTheme.blue, AppTheme.teal],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .opacity(configuration.isPressed ? 0.82 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct AppPanelSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.text)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(AppTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.border, lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct AppSegmentedPickerStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .pickerStyle(.segmented)
            .tint(AppTheme.blue)
            .padding(3)
            .background(AppTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 11))
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(AppTheme.border, lineWidth: 1)
            }
    }
}

private struct AppToolbarStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .tint(AppTheme.text)
    }
}

extension View {
    func appSegmentedPickerStyle() -> some View {
        modifier(AppSegmentedPickerStyleModifier())
    }

    func appToolbarStyle() -> some View {
        modifier(AppToolbarStyleModifier())
    }
}
