import Foundation

/// Use case responsible for updating existing TODO items.
struct UpdateTodoUseCase {
    private let repository: TodoRepository

    /// Creates the use case injecting its dependencies.
    /// - Parameter repository: Repository that persists todo items.
    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Executes the update process.
    /// - Parameter todo: Item to persist.
    func execute(todo: TodoItem) throws {
        try repository.update(todo: todo)
    }
}
