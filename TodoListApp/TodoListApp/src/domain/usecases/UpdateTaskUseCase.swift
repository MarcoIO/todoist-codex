import Foundation

/// Updates a task inside the repository.
public struct UpdateTaskUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(task: Task) throws {
        try repository.update(task: task)
    }
}
