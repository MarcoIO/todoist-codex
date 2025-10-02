import Foundation

/// Concrete repository that persists TODO items using a ``LocalTodoDataSource``.
final class TodoRepositoryImpl: TodoRepository {
    private let dataSource: LocalTodoDataSource

    /// Creates a repository connected to the provided data source.
    /// - Parameter dataSource: Local persistence layer abstraction.
    init(dataSource: LocalTodoDataSource) {
        self.dataSource = dataSource
    }

    func fetchTodos() throws -> [TodoItem] {
        try dataSource.loadTodos().map(TodoItem.init)
    }

    func fetchTodo(id: UUID) throws -> TodoItem? {
        try dataSource.loadTodos().first { $0.id == id }.map(TodoItem.init)
    }

    func create(todo: TodoItem) throws {
        var todos = try dataSource.loadTodos()
        todos.append(TodoEntity(todo: todo))
        try dataSource.saveTodos(todos)
    }

    func update(todo: TodoItem) throws {
        var todos = try dataSource.loadTodos()
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else {
            return
        }
        todos[index] = TodoEntity(todo: todo)
        try dataSource.saveTodos(todos)
    }
}

private extension TodoEntity {
    /// Convenience initializer to convert a domain model into an entity.
    /// - Parameter todo: The domain model instance.
    init(todo: TodoItem) {
        self.init(
            id: todo.id,
            icon: todo.icon,
            title: todo.title,
            details: todo.details,
            dueDate: todo.dueDate,
            isCompleted: todo.isCompleted
        )
    }
}
