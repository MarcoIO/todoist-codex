import Foundation

/// Raw representation of a task list persisted in Core Data.
public struct TaskListDataModel {
    public let identifier: UUID
    public var name: String
    public var categoryRaw: String
    public var tasks: [TaskDataModel]

    public init(
        identifier: UUID = UUID(),
        name: String,
        categoryRaw: String,
        tasks: [TaskDataModel] = []
    ) {
        self.identifier = identifier
        self.name = name
        self.categoryRaw = categoryRaw
        self.tasks = tasks
    }
}
