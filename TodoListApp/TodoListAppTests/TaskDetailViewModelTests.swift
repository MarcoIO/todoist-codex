import XCTest
@testable import TodoListApp

@MainActor
final class TaskDetailViewModelTests: XCTestCase {
    private var repository: TaskListRepositoryMock!
    private var viewModel: TaskDetailViewModel!
    private var task: Task!

    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = TaskListRepositoryMock()
        task = Task(
            iconName: "calendar",
            title: "Review",
            details: "Review agenda",
            dueDate: Date(),
            status: .pending,
            listID: UUID(),
            listName: "Work",
            category: .work
        )
        repository.lists = [TaskList(id: task.listID, name: task.listName, category: .work, tasks: [task])]
        repository.getTaskResult = .success(nil)
        viewModel = TaskDetailViewModel(
            taskIdentifier: task.id,
            getTaskByIDUseCase: GetTaskByIDUseCase(repository: repository),
            updateTaskUseCase: UpdateTaskUseCase(repository: repository)
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        repository = nil
        task = nil
        try super.tearDownWithError()
    }

    func testLoadTaskFetchesTask() throws {
        viewModel.loadTask()

        XCTAssertEqual(viewModel.task, task)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadTaskFailurePublishesError() throws {
        repository.getTaskResult = .failure(TaskDataSourceError.taskNotFound)

        viewModel.loadTask()

        XCTAssertEqual(viewModel.errorMessage, NSLocalizedString("error_task_not_found", comment: ""))
    }

    func testToggleStatusUpdatesTask() throws {
        viewModel.loadTask()

        viewModel.toggleStatus()

        XCTAssertEqual(viewModel.task?.status, .completed)
    }
}
