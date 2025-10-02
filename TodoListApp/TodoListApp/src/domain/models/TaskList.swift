import Foundation

/// Represents a collection of tasks grouped by context.
public struct TaskList: Identifiable, Equatable, Codable {
    public let id: UUID
    public var name: String
    public var category: TaskListCategory
    public var tasks: [Task]

    public init(
        id: UUID = UUID(),
        name: String,
        category: TaskListCategory,
        tasks: [Task] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.tasks = tasks
    }
}
