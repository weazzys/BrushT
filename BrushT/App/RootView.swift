import SwiftUI

struct RootView: View {
    @State private var isLaunchVisible = true

    var body: some View {
        ZStack {
            BrushListView()
                .opacity(isLaunchVisible ? 0 : 1)

            if isLaunchVisible {
                AppLaunchView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .onAppear(perform: hideLaunchScreen)
    }

    private func hideLaunchScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.45)) {
                isLaunchVisible = false
            }
        }
    }
}

private struct AppLaunchView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color("LaunchBackground")
                .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.18), lineWidth: 10)
                        .frame(width: 168, height: 168)

                    Circle()
                        .trim(from: 0, to: 0.72)
                        .stroke(
                            .white,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 168, height: 168)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            .linear(duration: 1.25).repeatForever(autoreverses: false),
                            value: isAnimating
                        )

                    Image("LaunchLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 108, height: 108)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .scaleEffect(isAnimating ? 1.05 : 0.96)
                        .shadow(color: .black.opacity(0.16), radius: 18, y: 8)
                        .animation(
                            .easeInOut(duration: 0.85).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .accessibilityHidden(true)
                }

                LoadingDotsView(isAnimating: isAnimating)
                    .accessibilityLabel("Загрузка")
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

private struct LoadingDotsView: View {
    let isAnimating: Bool

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(isAnimating ? 1 : 0.55))
                    .frame(width: 9, height: 9)
                    .scaleEffect(isAnimating ? 1.15 : 0.75)
                    .animation(
                        .easeInOut(duration: 0.55)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.16),
                        value: isAnimating
                    )
            }
        }
    }
}
