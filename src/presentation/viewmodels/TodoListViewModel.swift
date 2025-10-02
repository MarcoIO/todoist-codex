import Foundation

/// Represents the loading state of the todo list.
enum TodoListViewState: Equatable {
    case idle
    case loading
    case loaded([TodoListItemViewData])
    case failed(String)
}

/// View data for items displayed in the list.
struct TodoListItemViewData: Identifiable, Equatable {
    let id: UUID
    let icon: String
    let title: String
    let subtitle: String
    let dueDate: Date
    let isCompleted: Bool
}

/// View model coordinating the todo list presentation.
@MainActor
final class TodoListViewModel: ObservableObject {
    @Published private(set) var state: TodoListViewState = .idle

    private let getTodosUseCase: GetTodosUseCase
    private let updateTodoUseCase: UpdateTodoUseCase

    /// Creates the view model injecting the required use cases.
    /// - Parameters:
    ///   - getTodosUseCase: Use case to retrieve the todo list.
    ///   - updateTodoUseCase: Use case to persist updates.
    init(
        getTodosUseCase: GetTodosUseCase,
        updateTodoUseCase: UpdateTodoUseCase
    ) {
        self.getTodosUseCase = getTodosUseCase
        self.updateTodoUseCase = updateTodoUseCase
    }

    /// Loads the TODO list updating the published state.
    func load() {
        state = .loading
        do {
            let todos = try getTodosUseCase.execute()
            state = .loaded(todos.map(Self.mapToViewData(_:)))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Toggles the completion flag of the provided item.
    /// - Parameter item: View data representing the todo.
    func toggleCompletion(for item: TodoListItemViewData) {
        do {
            let updated = TodoItem(
                id: item.id,
                icon: item.icon,
                title: item.title,
                details: item.subtitle,
                dueDate: item.dueDate,
                isCompleted: !item.isCompleted
            )
            try updateTodoUseCase.execute(todo: updated)
            load()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private static func mapToViewData(_ todo: TodoItem) -> TodoListItemViewData {
        TodoListItemViewData(
            id: todo.id,
            icon: todo.icon,
            title: todo.title,
            subtitle: todo.details,
            dueDate: todo.dueDate,
            isCompleted: todo.isCompleted
        )
    }
}
