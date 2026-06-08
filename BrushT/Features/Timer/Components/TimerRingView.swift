import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let elapsed: TimeInterval

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.surfaceMuted, lineWidth: 14)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.blue, AppTheme.teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.2), value: progress)
        }
        .padding(8)
    }
}
