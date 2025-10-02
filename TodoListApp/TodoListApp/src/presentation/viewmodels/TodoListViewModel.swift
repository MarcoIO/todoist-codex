import Foundation
import Combine

/// View data representation for items in the list screen.
struct TodoListItemViewData: Identifiable, Equatable {
    let id: UUID
    let iconName: String
    let title: String
    let dueDate: Date
    let status: TodoStatus
}

/// Handles the business interaction for the TODO list screen.
final class TodoListViewModel: ObservableObject {
    @Published private(set) var items: [TodoListItemViewData] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let fetchTodosUseCase: FetchTodosUseCase
    private let deleteTodoUseCase: DeleteTodoUseCase

    init(fetchTodosUseCase: FetchTodosUseCase, deleteTodoUseCase: DeleteTodoUseCase) {
        self.fetchTodosUseCase = fetchTodosUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
    }

    func load() {
        isLoading = true
        errorMessage = nil
        do {
            let todos = try fetchTodosUseCase.execute()
            items = todos.map { todo in
                TodoListItemViewData(
                    id: todo.id,
                    iconName: todo.iconName,
                    title: todo.title,
                    dueDate: todo.dueDate,
                    status: todo.status
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func delete(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let identifier = items[index].id
        do {
            try deleteTodoUseCase.execute(identifier: identifier)
            items.remove(at: index)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
