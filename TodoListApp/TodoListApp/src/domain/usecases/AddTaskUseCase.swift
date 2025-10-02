import Foundation

/// Persists a new task inside a specific list.
public struct AddTaskToListUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(task: Task) throws {
        try repository.add(task: task)
    }
}
