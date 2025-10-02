import Foundation

/// Defines the contract for accessing and mutating TODO items.
public protocol TodoRepository {
    func fetchAll() throws -> [TodoItem]
    func get(by identifier: UUID) throws -> TodoItem
    func save(_ item: TodoItem) throws
    func delete(_ identifier: UUID) throws
}
