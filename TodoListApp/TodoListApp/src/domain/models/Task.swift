import Foundation

/// Domain representation of a task.
public struct Task: Identifiable, Equatable, Codable {
    public let id: UUID
    public var listID: UUID
    public var iconName: String
    public var title: String
    public var details: String
    public var dueDate: Date
    public var status: TaskStatus
    public var category: TaskCategory

    public init(
        id: UUID = UUID(),
        listID: UUID,
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        status: TaskStatus,
        category: TaskCategory
    ) {
        self.id = id
        self.listID = listID
        self.iconName = iconName
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.status = status
        self.category = category
    }
}
