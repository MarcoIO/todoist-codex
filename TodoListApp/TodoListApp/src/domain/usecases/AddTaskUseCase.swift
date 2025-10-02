import Foundation

/// Persists a new task inside a given list.
public struct AddTaskUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(task: Task, listID: UUID) throws {
        try repository.add(task: task, to: listID)
    }
}
