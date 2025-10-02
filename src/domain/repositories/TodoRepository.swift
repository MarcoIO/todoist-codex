import Foundation

/// Abstraction that exposes operations required to manage TODO items.
protocol TodoRepository {
    /// Retrieves all persisted TODO items.
    /// - Returns: List of domain models.
    func fetchTodos() throws -> [TodoItem]

    /// Retrieves a single TODO item by its identifier.
    /// - Parameter id: Identifier of the item to fetch.
    /// - Returns: The matching item or ``nil`` when it does not exist.
    func fetchTodo(id: UUID) throws -> TodoItem?

    /// Persists a new TODO item.
    /// - Parameter todo: Item to create.
    func create(todo: TodoItem) throws

    /// Updates an existing TODO item.
    /// - Parameter todo: Item with updated information.
    func update(todo: TodoItem) throws
}
