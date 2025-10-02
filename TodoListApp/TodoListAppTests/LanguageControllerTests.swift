import XCTest
@testable import TodoListApp

final class LanguageControllerTests: XCTestCase {
    private let suiteName = "LanguageControllerTests"
    private var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return XCTFail("Unable to create UserDefaults with custom suite.")
        }
        userDefaults = defaults
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        userDefaults?.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        try super.tearDownWithError()
    }

    func testInitializesWithStoredLanguage() {
        userDefaults.set(AppLanguage.spanish.rawValue, forKey: "selectedLanguage")

        let controller = LanguageController(storage: userDefaults)

        XCTAssertEqual(controller.currentLanguage, .spanish)
    }

    func testUpdateLanguagePersistsSelection() {
        let controller = LanguageController(storage: userDefaults)

        controller.updateLanguage(.spanish)

        XCTAssertEqual(controller.currentLanguage, .spanish)
        XCTAssertEqual(userDefaults.string(forKey: "selectedLanguage"), AppLanguage.spanish.rawValue)
    }

    func testUpdateLanguageDoesNotPersistWhenSameLanguage() {
        let controller = LanguageController(storage: userDefaults)

        controller.updateLanguage(controller.currentLanguage)

        XCTAssertNil(userDefaults.string(forKey: "selectedLanguage"))
    }
}
