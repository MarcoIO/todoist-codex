import Foundation

/// Retrieves a task by its identifier.
public struct GetTaskByIDUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(identifier: UUID) throws -> Task? {
        try repository.getTask(by: identifier)
    }
}
