import Foundation

/// View data representation for the detail screen.
struct TodoDetailViewData: Equatable {
    let iconName: String
    let title: String
    let details: String
    let dueDate: Date
    let status: TodoStatus
}

/// Handles interactions for the detail screen of a TODO item.
final class TodoDetailViewModel: ObservableObject {
    @Published private(set) var item: TodoDetailViewData?
    @Published private(set) var errorMessage: String?

    private let identifier: UUID
    private let getTodoDetailUseCase: GetTodoDetailUseCase
    private let saveTodoUseCase: SaveTodoUseCase

    init(identifier: UUID, getTodoDetailUseCase: GetTodoDetailUseCase, saveTodoUseCase: SaveTodoUseCase) {
        self.identifier = identifier
        self.getTodoDetailUseCase = getTodoDetailUseCase
        self.saveTodoUseCase = saveTodoUseCase
    }

    func load() {
        do {
            let todo = try getTodoDetailUseCase.execute(identifier: identifier)
            item = TodoDetailViewData(
                iconName: todo.iconName,
                title: todo.title,
                details: todo.details,
                dueDate: todo.dueDate,
                status: todo.status
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompletion() {
        guard var currentItem = item else { return }
        currentItem = TodoDetailViewData(
            iconName: currentItem.iconName,
            title: currentItem.title,
            details: currentItem.details,
            dueDate: currentItem.dueDate,
            status: currentItem.status == .completed ? .pending : .completed
        )
        do {
            let updated = TodoItem(
                id: identifier,
                iconName: currentItem.iconName,
                title: currentItem.title,
                details: currentItem.details,
                dueDate: currentItem.dueDate,
                status: currentItem.status
            )
            try saveTodoUseCase.execute(updated)
            item = currentItem
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
