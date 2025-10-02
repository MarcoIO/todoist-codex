import XCTest
@testable import TodoListApp

final class TaskUseCasesTests: XCTestCase {
    private var repository: TaskListRepositoryMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = TaskListRepositoryMock()
    }

    override func tearDownWithError() throws {
        repository = nil
        try super.tearDownWithError()
    }

    func testFetchTaskListsUseCaseReturnsStoredLists() throws {
        let list = TaskList(name: "Test", category: .work)
        repository.lists = [list]
        let useCase = FetchTaskListsUseCase(repository: repository)

        let result = try useCase.execute()

        XCTAssertEqual(result, [list])
    }

    func testAddTaskListUseCaseDelegatesToRepository() throws {
        let useCase = AddTaskListUseCase(repository: repository)
        let list = TaskList(name: "Errands", category: .errands)

        try useCase.execute(list: list)

        XCTAssertEqual(repository.lists.count, 1)
        XCTAssertEqual(repository.lists.first?.name, list.name)
    }

    func testDeleteTaskListUseCaseRemovesList() throws {
        let list = TaskList(name: "Personal", category: .personal)
        repository.lists = [list]
        let useCase = DeleteTaskListUseCase(repository: repository)

        try useCase.execute(identifier: list.id)

        XCTAssertTrue(repository.lists.isEmpty)
    }

    func testAddTaskToListUseCaseAddsTask() throws {
        var list = TaskList(name: "Health", category: .health)
        repository.lists = [list]
        let useCase = AddTaskToListUseCase(repository: repository)
        let task = Task(
            iconName: "heart.fill",
            title: "Run",
            details: "Morning run",
            dueDate: Date(),
            status: .pending,
            listID: list.id,
            listName: list.name,
            category: .health
        )

        try useCase.execute(task: task)

        list.tasks.append(task)
        XCTAssertEqual(repository.lists.first?.tasks, list.tasks)
    }

    func testUpdateTaskUseCaseUpdatesTask() throws {
        var task = Task(
            iconName: "star",
            title: "Focus",
            details: "Deep work session",
            dueDate: Date(),
            status: .pending,
            listID: UUID(),
            listName: "Work",
            category: .work
        )
        var list = TaskList(id: task.listID, name: task.listName, category: .work, tasks: [task])
        repository.lists = [list]
        let useCase = UpdateTaskUseCase(repository: repository)

        task.status = .completed
        try useCase.execute(task: task)

        list.tasks[0] = task
        XCTAssertEqual(repository.lists.first?.tasks, list.tasks)
    }

    func testUpdateTaskListUseCaseUpdatesList() throws {
        var list = TaskList(name: "Personal", category: .personal)
        repository.lists = [list]
        let useCase = UpdateTaskListUseCase(repository: repository)

        list.name = "Updated"
        list.category = .work

        try useCase.execute(list: list)

        XCTAssertEqual(repository.lists.first?.name, "Updated")
        XCTAssertEqual(repository.lists.first?.category, .work)
    }

    func testDeleteTaskUseCaseRemovesTask() throws {
        let task = Task(
            iconName: "clock",
            title: "Read",
            details: "Read a book",
            dueDate: Date(),
            status: .pending,
            listID: UUID(),
            listName: "Leisure",
            category: .leisure
        )
        let list = TaskList(id: task.listID, name: task.listName, category: .leisure, tasks: [task])
        repository.lists = [list]
        let useCase = DeleteTaskUseCase(repository: repository)

        try useCase.execute(identifier: task.id)

        XCTAssertTrue(repository.lists.first?.tasks.isEmpty ?? false)
    }

    func testGetTaskByIDUseCaseReturnsTask() throws {
        let task = Task(
            iconName: "calendar",
            title: "Plan",
            details: "Plan week",
            dueDate: Date(),
            status: .pending,
            listID: UUID(),
            listName: "Work",
            category: .work
        )
        let list = TaskList(id: task.listID, name: task.listName, category: .work, tasks: [task])
        repository.lists = [list]
        let useCase = GetTaskByIDUseCase(repository: repository)

        let fetched = try useCase.execute(identifier: task.id)

        XCTAssertEqual(fetched, task)
    }
}
