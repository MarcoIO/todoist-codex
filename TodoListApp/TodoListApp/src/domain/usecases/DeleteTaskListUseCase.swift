import Foundation

/// Deletes a task list and all of its tasks.
public struct DeleteTaskListUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(identifier: UUID) throws {
        try repository.deleteList(identifier: identifier)
    }
}
