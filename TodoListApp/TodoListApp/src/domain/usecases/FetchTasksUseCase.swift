import Foundation

/// Retrieves the available tasks from the repository.
public struct FetchTasksUseCase {
    private let repository: TaskRepository

    public init(repository: TaskRepository) {
        self.repository = repository
    }

    public func execute() throws -> [Task] {
        try repository.fetchTasks()
    }
}
