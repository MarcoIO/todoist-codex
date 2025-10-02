import Foundation

/// Updates a task state inside the repository.
public struct UpdateTaskStatusUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(task: Task) throws {
        try repository.update(task: task)
    }
}
