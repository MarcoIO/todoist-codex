import Foundation

/// Persistence representation for a TODO item stored in the local database.
struct TodoEntity: Codable {
    let id: UUID
    let iconName: String
    let title: String
    let details: String
    let dueDate: Date
    let status: TodoStatus
}

extension TodoEntity {
    init(item: TodoItem) {
        self.init(
            id: item.id,
            iconName: item.iconName,
            title: item.title,
            details: item.details,
            dueDate: item.dueDate,
            status: item.status
        )
    }

    func toDomain() -> TodoItem {
        TodoItem(
            id: id,
            iconName: iconName,
            title: title,
            details: details,
            dueDate: dueDate,
            status: status
        )
    }
}
