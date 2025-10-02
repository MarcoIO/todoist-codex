import Foundation

/// Removes a TODO item using the repository.
public struct DeleteTodoUseCase {
    private let repository: TodoRepository

    public init(repository: TodoRepository) {
        self.repository = repository
    }

    public func execute(identifier: UUID) throws {
        try repository.delete(identifier)
    }
}
