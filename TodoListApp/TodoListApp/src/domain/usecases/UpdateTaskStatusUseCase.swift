import Foundation

/// Updates an existing task.
public struct UpdateTaskStatusUseCase {
    private let repository: TaskRepository

    public init(repository: TaskRepository) {
        self.repository = repository
    }

    public func execute(task: Task) throws {
        try repository.update(task: task)
    }
}
