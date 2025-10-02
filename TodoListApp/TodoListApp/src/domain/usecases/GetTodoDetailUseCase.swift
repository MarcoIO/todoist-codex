import Foundation

/// Fetches a single TODO item from the repository.
public struct GetTodoDetailUseCase {
    private let repository: TodoRepository

    public init(repository: TodoRepository) {
        self.repository = repository
    }

    public func execute(identifier: UUID) throws -> TodoItem {
        try repository.get(by: identifier)
    }
}
