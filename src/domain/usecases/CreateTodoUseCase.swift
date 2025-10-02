import Foundation

/// Use case handling the creation of new TODO items.
struct CreateTodoUseCase {
    private let repository: TodoRepository

    /// Creates the use case injecting its dependencies.
    /// - Parameter repository: Repository that persists todo items.
    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Executes the creation process.
    /// - Parameter todo: Item to be created.
    func execute(todo: TodoItem) throws {
        try repository.create(todo: todo)
    }
}
