import Foundation

/// Retrieves a task by its identifier.
public struct GetTaskByIDUseCase {
    private let repository: TaskRepository

    public init(repository: TaskRepository) {
        self.repository = repository
    }

    public func execute(identifier: UUID) throws -> Task? {
        try repository.getTask(by: identifier)
    }
}
