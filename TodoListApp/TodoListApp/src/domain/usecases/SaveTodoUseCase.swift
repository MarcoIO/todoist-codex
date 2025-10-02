import Foundation

/// Persists a TODO item using the repository.
public struct SaveTodoUseCase {
    private let repository: TodoRepository

    public init(repository: TodoRepository) {
        self.repository = repository
    }

    public func execute(_ item: TodoItem) throws {
        try repository.save(item)
    }
}
