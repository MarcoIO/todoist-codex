import SwiftUI

/// Renders a text value resolved using the provided language manager.
struct LocalizedText: View {
    @EnvironmentObject private var languageManager: LanguageManager
    let key: String

    init(_ key: String) {
        self.key = key
    }

    var body: some View {
        Text(languageManager.localized(key))
    }
}
