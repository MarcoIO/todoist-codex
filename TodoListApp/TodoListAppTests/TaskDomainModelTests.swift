import XCTest
@testable import TodoListApp

final class TaskDomainModelTests: XCTestCase {
    func testTaskCategoryLocalizationKeys() {
        XCTAssertEqual(TaskCategory.work.localizationKey, "category_work")
        XCTAssertEqual(TaskCategory.shopping.localizationKey, "category_shopping")
        XCTAssertEqual(TaskCategory.leisure.localizationKey, "category_leisure")
        XCTAssertEqual(TaskCategory.personal.localizationKey, "category_personal")
        XCTAssertEqual(TaskCategory.health.localizationKey, "category_health")
        XCTAssertEqual(TaskCategory.errands.localizationKey, "category_errands")
    }

    func testTaskCategoryIconNames() {
        XCTAssertEqual(TaskCategory.work.iconName, "briefcase.fill")
        XCTAssertEqual(TaskCategory.shopping.iconName, "cart.fill")
        XCTAssertEqual(TaskCategory.leisure.iconName, "gamecontroller.fill")
        XCTAssertEqual(TaskCategory.personal.iconName, "person.crop.circle.fill")
        XCTAssertEqual(TaskCategory.health.iconName, "heart.fill")
        XCTAssertEqual(TaskCategory.errands.iconName, "checklist")
    }

    func testTaskStatusLocalization() {
        XCTAssertEqual(TaskStatus.pending.localizationKey, NSLocalizedString("task_status_pending", comment: ""))
        XCTAssertEqual(TaskStatus.completed.localizationKey, NSLocalizedString("task_status_completed", comment: ""))
    }

    func testTaskEqualityComparesAllProperties() {
        let dueDate = Date()
        let firstTask = Task(
            iconName: "calendar",
            title: "Plan",
            details: "Plan tasks",
            dueDate: dueDate,
            status: .pending,
            listID: UUID(),
            listName: "Work",
            category: .work
        )

        var modifiedTask = firstTask
        modifiedTask.title = "Plan more"

        XCTAssertNotEqual(firstTask, modifiedTask)
    }

    func testTaskListInitializesWithEmptyTasks() {
        let list = TaskList(name: "Inbox", category: .work)
        XCTAssertTrue(list.tasks.isEmpty)
    }
}
