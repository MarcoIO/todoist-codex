import Foundation
import Combine

/// Represents the available languages supported by the application.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .spanish:
            return "Español"
        }
    }
}

/// Provides manual localization capabilities decoupled from system preferences.
final class LanguageManager: ObservableObject {
    @Published var current: AppLanguage {
        didSet {
            persist(language: current)
            bundle = Self.bundle(for: current)
        }
    }

    private var bundle: Bundle

    init(storage: UserDefaults = .standard) {
        if let stored = storage.string(forKey: Self.storageKey), let language = AppLanguage(rawValue: stored) {
            current = language
        } else {
            current = .english
        }
        bundle = Self.bundle(for: current)
    }

    func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    private func persist(language: AppLanguage, storage: UserDefaults = .standard) {
        storage.set(language.rawValue, forKey: Self.storageKey)
    }

    private static func bundle(for language: AppLanguage) -> Bundle {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }

    private static let storageKey = "appLanguage"
}
