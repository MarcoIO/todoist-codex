import Foundation

/// Data transfer object representing a persisted TODO item.
struct TodoEntity: Codable, Identifiable {
    /// Unique identifier for the entity.
    let id: UUID
    /// Icon identifier using SF Symbols names.
    let icon: String
    /// Title of the todo entry.
    let title: String
    /// Detailed description of the todo entry.
    let details: String
    /// Scheduled date for the todo entry.
    let dueDate: Date
    /// Completion flag stored in the persistence layer.
    let isCompleted: Bool

    /// Creates a copy of the entity applying optional changes.
    /// - Parameters:
    ///   - icon: Optional icon replacement.
    ///   - title: Optional title replacement.
    ///   - details: Optional details replacement.
    ///   - dueDate: Optional date replacement.
    ///   - isCompleted: Optional completion flag replacement.
    /// - Returns: A modified copy of the entity.
    func updating(
        icon: String? = nil,
        title: String? = nil,
        details: String? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool? = nil
    ) -> TodoEntity {
        TodoEntity(
            id: id,
            icon: icon ?? self.icon,
            title: title ?? self.title,
            details: details ?? self.details,
            dueDate: dueDate ?? self.dueDate,
            isCompleted: isCompleted ?? self.isCompleted
        )
    }
}
