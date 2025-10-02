import Foundation

/// Removes a task from persistence.
public struct DeleteTaskUseCase {
    private let repository: TaskRepository

    public init(repository: TaskRepository) {
        self.repository = repository
    }

    public func execute(identifier: UUID) throws {
        try repository.delete(identifier: identifier)
    }
}
