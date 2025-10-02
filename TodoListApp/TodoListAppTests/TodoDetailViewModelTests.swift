import XCTest
@testable import TodoListApp

final class TodoDetailViewModelTests: XCTestCase {
    func testToggleCompletionUpdatesStatus() throws {
        let repository = TodoRepositoryStub()
        let identifier = UUID()
        let item = TodoItem(id: identifier, iconName: "star", title: "Title", details: "Details", dueDate: Date(), status: .pending)
        repository.items = [item]

        let viewModel = TodoDetailViewModel(
            identifier: identifier,
            getTodoDetailUseCase: GetTodoDetailUseCase(repository: repository),
            saveTodoUseCase: SaveTodoUseCase(repository: repository)
        )

        viewModel.load()
        viewModel.toggleCompletion()

        XCTAssertEqual(viewModel.item?.status, .completed)
        XCTAssertEqual(repository.items.first?.status, .completed)
    }
}
