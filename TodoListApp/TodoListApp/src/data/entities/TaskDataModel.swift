import Foundation

/// Raw representation of a task used inside the data layer.
public struct TaskDataModel {
    public let identifier: UUID
    public var iconName: String
    public var title: String
    public var details: String
    public var dueDate: Date
    public var statusRaw: String

    public init(
        identifier: UUID = UUID(),
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        statusRaw: String
    ) {
        self.identifier = identifier
        self.iconName = iconName
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.statusRaw = statusRaw
    }
}
