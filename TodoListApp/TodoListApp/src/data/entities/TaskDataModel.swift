import Foundation

/// Raw representation of a task used inside the data layer.
public struct TaskDataModel {
    public let identifier: UUID
    public let listIdentifier: UUID
    public var iconName: String
    public var title: String
    public var details: String
    public var dueDate: Date
    public var statusRaw: String
    public var categoryRaw: String

    public init(
        identifier: UUID = UUID(),
        listIdentifier: UUID,
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        statusRaw: String,
        categoryRaw: String
    ) {
        self.identifier = identifier
        self.listIdentifier = listIdentifier
        self.iconName = iconName
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.statusRaw = statusRaw
        self.categoryRaw = categoryRaw
    }
}
