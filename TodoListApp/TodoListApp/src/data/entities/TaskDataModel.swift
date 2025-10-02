import Foundation

/// Raw representation of a task used inside the data layer.
public struct TaskDataModel {
    public let identifier: UUID
    public var iconName: String
    public var title: String
    public var details: String
    public var dueDate: Date
    public var statusRaw: String
    public var listIdentifier: UUID
    public var listName: String
    public var categoryRaw: String

    public init(
        identifier: UUID = UUID(),
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        statusRaw: String,
        listIdentifier: UUID,
        listName: String,
        categoryRaw: String
    ) {
        self.identifier = identifier
        self.iconName = iconName
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.statusRaw = statusRaw
        self.listIdentifier = listIdentifier
        self.listName = listName
        self.categoryRaw = categoryRaw
    }
}
