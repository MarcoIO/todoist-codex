import Foundation

/// Domain representation of a task.
public struct Task: Identifiable, Equatable, Codable {
    public let id: UUID
    public var iconName: String
    public var title: String
    public var details: String
    public var dueDate: Date
    public var status: TaskStatus

    public init(
        id: UUID = UUID(),
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        status: TaskStatus
    ) {
        self.id = id
        self.iconName = iconName
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.status = status
    }
}
