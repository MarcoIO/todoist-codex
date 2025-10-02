import Foundation

/// Persists a new task list in the repository.
public struct AddTaskListUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(list: TaskList) throws {
        try repository.add(list: list)
    }
}
