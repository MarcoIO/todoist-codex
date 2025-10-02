import Foundation

/// Represents the available states for a TODO item in the domain layer.
public enum TodoStatus: String, Codable, CaseIterable, Equatable {
    case pending
    case inProgress
    case completed
}

/// Domain model describing a TODO task with all business relevant attributes.
public struct TodoItem: Identifiable, Equatable {
    public let id: UUID
    public var iconName: String
    public var title: String
    public var details: String
    public var dueDate: Date
    public var status: TodoStatus

    public init(
        id: UUID = UUID(),
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        status: TodoStatus
    ) {
        self.id = id
        self.iconName = iconName
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.status = status
    }
}
