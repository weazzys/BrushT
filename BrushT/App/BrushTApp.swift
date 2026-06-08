import SwiftUI

@main
struct BrushTApp: App {
    init() {
        AppAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
