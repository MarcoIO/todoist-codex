import Foundation

/// Updates the metadata of an existing task list.
public struct UpdateTaskListUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(list: TaskList) throws {
        try repository.update(list: list)
    }
}
