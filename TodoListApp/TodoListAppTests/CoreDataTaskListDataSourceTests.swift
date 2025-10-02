import XCTest
import CoreData
@testable import TodoListApp

final class CoreDataTaskListDataSourceTests: XCTestCase {
    private var persistence: PersistenceController!
    private var dataSource: CoreDataTaskListDataSource!

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistence = PersistenceController(inMemory: true)
        dataSource = CoreDataTaskListDataSource(context: persistence.container.viewContext)
    }

    override func tearDownWithError() throws {
        dataSource = nil
        persistence = nil
        try super.tearDownWithError()
    }

    func testAddListPersistsList() throws {
        let identifier = UUID()
        let list = TaskListDataModel(
            identifier: identifier,
            name: "Today",
            categoryRaw: TaskCategory.work.rawValue,
            tasks: []
        )

        try dataSource.add(list: list)

        let storedLists = try dataSource.fetchLists()
        XCTAssertEqual(storedLists.count, 1)
        XCTAssertEqual(storedLists.first?.identifier, identifier)
    }

    func testAddTaskWithoutListThrows() {
        let task = TaskDataModel(
            iconName: "checkmark",
            title: "Review",
            details: "Weekly review",
            dueDate: Date(),
            statusRaw: TaskStatus.pending.rawValue,
            listIdentifier: UUID(),
            listName: "Planning",
            categoryRaw: TaskCategory.work.rawValue
        )

        XCTAssertThrowsError(try dataSource.add(task: task)) { error in
            guard case TaskDataSourceError.listNotFound = error as? TaskDataSourceError else {
                return XCTFail("Expected listNotFound error")
            }
        }
    }

    func testUpdateTaskChangesPersistedValues() throws {
        let list = TaskListDataModel(
            identifier: UUID(),
            name: "Personal",
            categoryRaw: TaskCategory.personal.rawValue,
            tasks: []
        )
        try dataSource.add(list: list)

        let task = TaskDataModel(
            iconName: "sun.max",
            title: "Meditate",
            details: "Take ten minutes",
            dueDate: Date(),
            statusRaw: TaskStatus.pending.rawValue,
            listIdentifier: list.identifier,
            listName: list.name,
            categoryRaw: TaskCategory.personal.rawValue
        )
        try dataSource.add(task: task)

        var updatedTask = task
        updatedTask.title = "Meditate deeply"
        updatedTask.statusRaw = TaskStatus.completed.rawValue
        try dataSource.update(task: updatedTask)

        let storedTask = try dataSource.getTask(by: task.identifier)
        XCTAssertEqual(storedTask?.title, "Meditate deeply")
        XCTAssertEqual(storedTask?.statusRaw, TaskStatus.completed.rawValue)
    }

    func testEnsureInitialDataSeedsEmptyStore() throws {
        try dataSource.ensureInitialData {
            let listID = UUID()
            let task = TaskDataModel(
                iconName: "calendar",
                title: "Plan",
                details: "Plan the week",
                dueDate: Date(),
                statusRaw: TaskStatus.pending.rawValue,
                listIdentifier: listID,
                listName: "Planning",
                categoryRaw: TaskCategory.work.rawValue
            )

            return [TaskListDataModel(
                identifier: listID,
                name: "Planning",
                categoryRaw: TaskCategory.work.rawValue,
                tasks: [task]
            )]
        }

        let storedLists = try dataSource.fetchLists()
        XCTAssertEqual(storedLists.count, 1)
        XCTAssertEqual(storedLists.first?.tasks.count, 1)
    }
}
