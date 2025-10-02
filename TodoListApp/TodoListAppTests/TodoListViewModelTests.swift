import XCTest
@testable import TodoListApp

final class TodoListViewModelTests: XCTestCase {
    func testLoadPopulatesItems() {
        let repository = TodoRepositoryStub()
        let todo = TodoItem(iconName: "star", title: "Title", details: "Details", dueDate: Date(), status: .pending)
        repository.items = [todo]

        let viewModel = TodoListViewModel(
            fetchTodosUseCase: FetchTodosUseCase(repository: repository),
            deleteTodoUseCase: DeleteTodoUseCase(repository: repository)
        )

        viewModel.load()
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.title, "Title")
    }

    func testDeleteRemovesItemFromList() {
        let repository = TodoRepositoryStub()
        let todo = TodoItem(iconName: "star", title: "Title", details: "Details", dueDate: Date(), status: .pending)
        repository.items = [todo]

        let viewModel = TodoListViewModel(
            fetchTodosUseCase: FetchTodosUseCase(repository: repository),
            deleteTodoUseCase: DeleteTodoUseCase(repository: repository)
        )

        viewModel.load()
        viewModel.delete(at: IndexSet(integer: 0))

        XCTAssertTrue(viewModel.items.isEmpty)
        XCTAssertEqual(repository.deletedIdentifier, todo.id)
    }
}
