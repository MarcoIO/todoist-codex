import Foundation

/// Retrieves the available task lists from the repository.
public struct FetchTaskListsUseCase {
    private let repository: TaskListRepository

    public init(repository: TaskListRepository) {
        self.repository = repository
    }

    public func execute() throws -> [TaskList] {
        try repository.fetchLists()
    }
}
