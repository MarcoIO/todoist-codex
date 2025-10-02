import XCTest
@testable import TodoListApp

private final class TodoRepositorySpy: TodoRepository {
    var items: [TodoItem] = []

    func fetchAll() throws -> [TodoItem] {
        items
    }

    func get(by identifier: UUID) throws -> TodoItem {
        guard let item = items.first(where: { $0.id == identifier }) else {
            throw NSError(domain: "test", code: 0)
        }
        return item
    }

    func save(_ item: TodoItem) throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    func delete(_ identifier: UUID) throws {
        items.removeAll { $0.id == identifier }
    }
}

final class UseCaseTests: XCTestCase {
    func testFetchTodosReturnsItems() throws {
        let repository = TodoRepositorySpy()
        let todo = TodoItem(iconName: "star", title: "Title", details: "Details", dueDate: Date(), status: .pending)
        repository.items = [todo]
        let useCase = FetchTodosUseCase(repository: repository)
        XCTAssertEqual(try useCase.execute(), [todo])
    }

    func testSaveTodoPersistsChanges() throws {
        let repository = TodoRepositorySpy()
        let todo = TodoItem(iconName: "star", title: "Title", details: "Details", dueDate: Date(), status: .pending)
        let useCase = SaveTodoUseCase(repository: repository)
        try useCase.execute(todo)
        XCTAssertEqual(repository.items.count, 1)
    }
}
