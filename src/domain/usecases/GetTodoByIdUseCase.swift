import Foundation

/// Use case that returns a TODO item by its identifier.
struct GetTodoByIdUseCase {
    private let repository: TodoRepository

    /// Creates the use case with the provided repository dependency.
    /// - Parameter repository: Repository to query TODO items.
    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Executes the lookup.
    /// - Parameter id: Identifier of the item to retrieve.
    /// - Returns: The matching todo item or ``nil``.
    func execute(id: UUID) throws -> TodoItem? {
        try repository.fetchTodo(id: id)
    }
}
