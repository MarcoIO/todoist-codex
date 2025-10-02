import Foundation

/// Domain representation of a TODO item used across the application layers.
struct TodoItem: Identifiable, Equatable {
    /// Unique identifier for the item.
    let id: UUID
    /// Icon name displayed in the UI.
    let icon: String
    /// Title describing the task.
    let title: String
    /// Detailed description for the task.
    let details: String
    /// Due date scheduled for the task.
    let dueDate: Date
    /// Completion flag representing the business state.
    let isCompleted: Bool

    /// Provides a modified copy of the item.
    /// - Parameters match the struct properties to override when needed.
    /// - Returns: A new ``TodoItem`` reflecting the specified changes.
    func updating(
        icon: String? = nil,
        title: String? = nil,
        details: String? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool? = nil
    ) -> TodoItem {
        TodoItem(
            id: id,
            icon: icon ?? self.icon,
            title: title ?? self.title,
            details: details ?? self.details,
            dueDate: dueDate ?? self.dueDate,
            isCompleted: isCompleted ?? self.isCompleted
        )
    }
}

extension TodoItem {
    /// Creates a domain item from a data entity.
    /// - Parameter entity: The entity to convert.
    init(entity: TodoEntity) {
        self.init(
            id: entity.id,
            icon: entity.icon,
            title: entity.title,
            details: entity.details,
            dueDate: entity.dueDate,
            isCompleted: entity.isCompleted
        )
    }
}
