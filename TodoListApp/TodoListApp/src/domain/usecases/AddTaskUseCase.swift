import Foundation

/// Persists a new task.
public struct AddTaskUseCase {
    private let repository: TaskRepository

    public init(repository: TaskRepository) {
        self.repository = repository
    }

    public func execute(task: Task) throws {
        try repository.add(task: task)
    }
}
