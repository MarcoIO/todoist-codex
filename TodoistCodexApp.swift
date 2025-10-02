import SwiftUI

/// Entry point for the TodoistCodex application.
@main
struct TodoistCodexApp: App {
    private let composition = TodoAppComposition()

    var body: some Scene {
        WindowGroup {
            composition.makeRootView()
        }
    }
}
