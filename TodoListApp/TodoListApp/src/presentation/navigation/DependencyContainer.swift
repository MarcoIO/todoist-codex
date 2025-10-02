import Foundation

/// Assembles the dependencies across data, domain and presentation layers.
final class DependencyContainer: ObservableObject {
    private let repository: TodoRepository

    init() {
        let dataSource = LocalTodoDataSource()
        repository = TodoRepositoryImpl(dataSource: dataSource)
    }

    func listViewModel() -> TodoListViewModel {
        TodoListViewModel(
            fetchTodosUseCase: FetchTodosUseCase(repository: repository),
            deleteTodoUseCase: DeleteTodoUseCase(repository: repository)
        )
    }

    func detailViewModel(identifier: UUID) -> TodoDetailViewModel {
        TodoDetailViewModel(
            identifier: identifier,
            getTodoDetailUseCase: GetTodoDetailUseCase(repository: repository),
            saveTodoUseCase: SaveTodoUseCase(repository: repository)
        )
    }
}
