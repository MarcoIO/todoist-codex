import Foundation

/// Persists a new task list.
public struct AddTaskListUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(list: TaskList) throws {
        try repository.add(list: list)
    }
}
