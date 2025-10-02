import Foundation

/// Domain representation of a task.
public struct Task: Identifiable, Equatable, Codable {
    public static let defaultIconName = "checkmark.circle"

    public let id: UUID
    public var iconName: String
    public var title: String
    public var details: String
    public var dueDate: Date
    public var status: TaskStatus
    public var listID: UUID
    public var listName: String
    public var category: TaskCategory

    public init(
        id: UUID = UUID(),
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        status: TaskStatus,
        listID: UUID,
        listName: String,
        category: TaskCategory
    ) {
        self.id = id
        self.iconName = iconName
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.status = status
        self.listID = listID
        self.listName = listName
        self.category = category
    }
}
