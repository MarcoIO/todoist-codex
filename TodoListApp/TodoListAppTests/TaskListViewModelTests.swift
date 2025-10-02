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
            updateTaskUseCase: UpdateTaskUseCase(repository: repository),
            deleteTaskUseCase: DeleteTaskUseCase(repository: repository),
            updateTaskListUseCase: UpdateTaskListUseCase(repository: repository)
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

    func testUpdateTaskModifiesTaskInformation() throws {
        var task = Task(
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

        let updatedTitle = "Updated"
        let updatedDetails = "Call two friends"
        let updatedDate = Date().addingTimeInterval(3600)
        let updatedCategory: TaskCategory = .work

        viewModel.updateTask(
            storedTask,
            title: updatedTitle,
            details: updatedDetails,
            dueDate: updatedDate,
            category: updatedCategory
        )

        let reloadedTask = viewModel.lists.first?.tasks.first
        XCTAssertEqual(reloadedTask?.title, updatedTitle)
        XCTAssertEqual(reloadedTask?.details, updatedDetails)
        XCTAssertEqual(reloadedTask?.category, updatedCategory)
        if let reloadedDate = reloadedTask?.dueDate.timeIntervalSinceReferenceDate {
            XCTAssertEqual(reloadedDate, updatedDate.timeIntervalSinceReferenceDate, accuracy: 0.5)
        } else {
            XCTFail("Expected a task date to be available")
        }
    }

    func testUpdateListChangesNameAndCategory() throws {
        let list = TaskList(name: "Personal", category: .personal)
        repository.lists = [list]
        viewModel.loadLists()

        guard let storedList = viewModel.lists.first else {
            return XCTFail("Expected a list to be loaded")
        }

        viewModel.update(list: storedList, name: "Updated", category: .work)

        XCTAssertEqual(viewModel.lists.first?.name, "Updated")
        XCTAssertEqual(viewModel.lists.first?.category, .work)
    }
}
