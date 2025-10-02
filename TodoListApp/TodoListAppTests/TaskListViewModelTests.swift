import XCTest
@testable import TodoListApp

@MainActor
final class TaskListViewModelTests: XCTestCase {
    private var repository: TaskListRepositoryMock!
    private var viewModel: TaskListViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = TaskListRepositoryMock()
        viewModel = TaskListViewModel(
            fetchTaskListsUseCase: FetchTaskListsUseCase(repository: repository),
            addTaskListUseCase: AddTaskListUseCase(repository: repository),
            deleteTaskListUseCase: DeleteTaskListUseCase(repository: repository),
            addTaskUseCase: AddTaskToListUseCase(repository: repository),
            updateTaskStatusUseCase: UpdateTaskStatusUseCase(repository: repository),
            deleteTaskUseCase: DeleteTaskUseCase(repository: repository)
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        repository = nil
        try super.tearDownWithError()
    }

    func testLoadListsPublishesRepositoryLists() throws {
        let task = Task(
            iconName: "star",
            title: "Focus",
            details: "Work on key project",
            dueDate: Date(),
            status: .pending,
            listID: UUID(),
            listName: "Work",
            category: .work
        )
        repository.lists = [TaskList(id: task.listID, name: task.listName, category: .work, tasks: [task])]

        viewModel.loadLists()

        XCTAssertEqual(viewModel.lists, repository.lists)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testAddListFailurePublishesLocalizedError() {
        repository.addListError = TaskDataSourceError.unknown

        viewModel.addList(name: "Home", category: .personal)

        XCTAssertEqual(viewModel.errorMessage, NSLocalizedString("error_unknown", comment: ""))
    }

    func testDeleteTaskUpdatesLists() throws {
        let task = Task(
            iconName: "clock",
            title: "Read",
            details: "Read a chapter",
            dueDate: Date(),
            status: .pending,
            listID: UUID(),
            listName: "Leisure",
            category: .leisure
        )
        repository.lists = [TaskList(id: task.listID, name: task.listName, category: .leisure, tasks: [task])]
        viewModel.loadLists()

        guard let storedTask = viewModel.lists.first?.tasks.first else {
            return XCTFail("Expected a task to be loaded")
        }

        viewModel.deleteTask(storedTask)

        XCTAssertTrue(viewModel.lists.first?.tasks.isEmpty ?? false)
    }

    func testToggleStatusUpdatesTaskState() throws {
        let task = Task(
            iconName: "bell",
            title: "Reminder",
            details: "Call a friend",
            dueDate: Date(),
            status: .pending,
            listID: UUID(),
            listName: "Personal",
            category: .personal
        )
        repository.lists = [TaskList(id: task.listID, name: task.listName, category: .personal, tasks: [task])]
        viewModel.loadLists()

        guard let storedTask = viewModel.lists.first?.tasks.first else {
            return XCTFail("Expected a task to be loaded")
        }

        viewModel.toggleStatus(for: storedTask)

        XCTAssertEqual(viewModel.lists.first?.tasks.first?.status, .completed)
    }
}
