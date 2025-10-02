import SwiftUI

@main
struct TodoListApp: App {
    @StateObject private var dependencyContainer = DependencyContainer()
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            TodoListView(viewModel: dependencyContainer.listViewModel())
                .environmentObject(dependencyContainer)
                .environmentObject(languageManager)
        }
    }
}
