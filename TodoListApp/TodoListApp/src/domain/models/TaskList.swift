import Foundation

/// Domain representation of a task list grouping several tasks.
public struct TaskList: Identifiable, Equatable, Codable {
    public let id: UUID
    public var name: String
    public var category: TaskCategory
    public var tasks: [Task]

    public init(
        id: UUID = UUID(),
        name: String,
        category: TaskCategory,
        tasks: [Task] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.tasks = tasks
    }
}
