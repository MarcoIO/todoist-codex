import Foundation

/// Abstraction for task list persistence operations.
public protocol TaskListRepository {
    func fetchLists() throws -> [TaskList]
    func add(list: TaskList) throws
    func update(list: TaskList) throws
    func deleteList(identifier: UUID) throws
    func add(task: Task) throws
    func update(task: Task) throws
    func deleteTask(identifier: UUID) throws
    func getTask(by identifier: UUID) throws -> Task?
}
