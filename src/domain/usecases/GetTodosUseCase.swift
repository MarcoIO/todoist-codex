import Foundation

/// Use case responsible for retrieving the list of TODO items.
struct GetTodosUseCase {
    private let repository: TodoRepository

    /// Creates the use case providing the required repository dependency.
    /// - Parameter repository: Repository that persists todo items.
    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Executes the use case.
    /// - Returns: Collection of ``TodoItem``.
    func execute() throws -> [TodoItem] {
        try repository.fetchTodos().sorted { $0.dueDate < $1.dueDate }
    }
}
