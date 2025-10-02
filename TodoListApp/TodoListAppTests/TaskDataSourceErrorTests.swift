import XCTest
@testable import TodoListApp

final class TaskDataSourceErrorTests: XCTestCase {
    func testListNotFoundLocalizedDescription() {
        let error = TaskDataSourceError.listNotFound
        XCTAssertEqual(error.errorDescription, NSLocalizedString("error_list_not_found", comment: ""))
    }

    func testTaskNotFoundLocalizedDescription() {
        let error = TaskDataSourceError.taskNotFound
        XCTAssertEqual(error.errorDescription, NSLocalizedString("error_task_not_found", comment: ""))
    }

    func testUnknownErrorLocalizedDescription() {
        let error = TaskDataSourceError.unknown
        XCTAssertEqual(error.errorDescription, NSLocalizedString("error_unknown", comment: ""))
    }
}
