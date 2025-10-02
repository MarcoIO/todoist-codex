import Foundation
@testable import TodoListApp

final class TodoRepositoryStub: TodoRepository {
    var items: [TodoItem] = []
    var deletedIdentifier: UUID?

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
        deletedIdentifier = identifier
        items.removeAll { $0.id == identifier }
    }
}
