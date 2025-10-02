import Foundation

/// Concrete repository that bridges the domain layer with the local data source.
final class TodoRepositoryImpl: TodoRepository {
    private let dataSource: LocalTodoDataSource

    init(dataSource: LocalTodoDataSource) {
        self.dataSource = dataSource
    }

    func fetchAll() throws -> [TodoItem] {
        try dataSource.fetchAll().map { $0.toDomain() }.sorted { $0.dueDate < $1.dueDate }
    }

    func get(by identifier: UUID) throws -> TodoItem {
        try dataSource.get(by: identifier).toDomain()
    }

    func save(_ item: TodoItem) throws {
        let entity = TodoEntity(item: item)
        try dataSource.save(entity)
    }

    func delete(_ identifier: UUID) throws {
        try dataSource.delete(identifier)
    }
}
