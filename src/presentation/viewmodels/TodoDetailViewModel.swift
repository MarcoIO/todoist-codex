import Foundation

/// Represents the detailed information displayed in the detail screen.
struct TodoDetailViewData {
    let id: UUID
    let icon: String
    let title: String
    let details: String
    let dueDate: Date
    let isCompleted: Bool
}

/// States handled by ``TodoDetailViewModel``.
enum TodoDetailViewState: Equatable {
    case idle
    case loading
    case loaded(TodoDetailViewData)
    case failed(String)
}

/// View model that exposes the detail of a TODO item.
@MainActor
final class TodoDetailViewModel: ObservableObject {
    @Published private(set) var state: TodoDetailViewState = .idle

    private let getTodoByIdUseCase: GetTodoByIdUseCase
    private let updateTodoUseCase: UpdateTodoUseCase

    /// Creates the view model.
    /// - Parameters:
    ///   - getTodoByIdUseCase: Use case to load a single todo entry.
    ///   - updateTodoUseCase: Use case to persist modifications.
    init(
        getTodoByIdUseCase: GetTodoByIdUseCase,
        updateTodoUseCase: UpdateTodoUseCase
    ) {
        self.getTodoByIdUseCase = getTodoByIdUseCase
        self.updateTodoUseCase = updateTodoUseCase
    }

    /// Loads the detail of the specified todo identifier.
    /// - Parameter id: Identifier of the todo item.
    func load(id: UUID) {
        state = .loading
        do {
            guard let todo = try getTodoByIdUseCase.execute(id: id) else {
                state = .failed("La tarea no existe")
                return
            }
            state = .loaded(Self.map(todo: todo))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Toggles the completion flag of the currently loaded todo item.
    func toggleCompletion() {
        guard case let .loaded(data) = state else {
            return
        }
        do {
            let updated = TodoItem(
                id: data.id,
                icon: data.icon,
                title: data.title,
                details: data.details,
                dueDate: data.dueDate,
                isCompleted: !data.isCompleted
            )
            try updateTodoUseCase.execute(todo: updated)
            load(id: data.id)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private static func map(todo: TodoItem) -> TodoDetailViewData {
        TodoDetailViewData(
            id: todo.id,
            icon: todo.icon,
            title: todo.title,
            details: todo.details,
            dueDate: todo.dueDate,
            isCompleted: todo.isCompleted
        )
    }
}
