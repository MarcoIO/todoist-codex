import Foundation

/// Retrieves all TODO items available in the repository.
public struct FetchTodosUseCase {
    private let repository: TodoRepository

    public init(repository: TodoRepository) {
        self.repository = repository
    }

    public func execute() throws -> [TodoItem] {
        try repository.fetchAll()
    }
}
