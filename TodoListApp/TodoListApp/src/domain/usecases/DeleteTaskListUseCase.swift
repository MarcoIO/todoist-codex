import Foundation

/// Removes a task list from the repository.
public struct DeleteTaskListUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute(identifier: UUID) throws {
        try repository.deleteList(identifier: identifier)
    }
}
