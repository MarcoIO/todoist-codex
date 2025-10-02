import Foundation
import SwiftUI

/// Supported languages in the application.
public enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    public var id: String { rawValue }

    public var displayNameKey: LocalizedStringKey {
        switch self {
        case .english:
            return "language_english"
        case .spanish:
            return "language_spanish"
        }
    }

    public var localeIdentifier: String { rawValue }
}

/// Handles language selection and persistence.
public final class LanguageController: ObservableObject {
    @Published public private(set) var currentLanguage: AppLanguage

    private let storageKey = "selectedLanguage"
    private let storage: UserDefaults

    public init(storage: UserDefaults = .standard) {
        self.storage = storage
        if let value = storage.string(forKey: storageKey),
           let language = AppLanguage(rawValue: value) {
            currentLanguage = language
        } else {
            let systemCode = Locale.current.languageCode ?? "en"
            currentLanguage = AppLanguage(rawValue: systemCode) ?? .english
        }
    }

    public func updateLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        storage.set(language.rawValue, forKey: storageKey)
    }
}
