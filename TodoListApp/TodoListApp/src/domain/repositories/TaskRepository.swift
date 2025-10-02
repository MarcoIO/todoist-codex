import Foundation

/// Abstraction for task persistence operations.
public protocol TaskRepository {
    func fetchTasks() throws -> [Task]
    func getTask(by identifier: UUID) throws -> Task?
    func add(task: Task) throws
    func update(task: Task) throws
    func delete(identifier: UUID) throws
}
