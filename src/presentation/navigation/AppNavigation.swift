import SwiftUI

/// Provides dependency injection helpers for the TODO application.
struct TodoAppComposition {
    private let dataSource: LocalTodoDataSource
    private let repository: TodoRepository
    private let getTodosUseCase: GetTodosUseCase
    private let getTodoByIdUseCase: GetTodoByIdUseCase
    private let updateTodoUseCase: UpdateTodoUseCase

    /// Creates the composition root setting up default dependencies.
    init() {
        let dataSource = JsonFileTodoDataSource()
        let repository = TodoRepositoryImpl(dataSource: dataSource)
        self.dataSource = dataSource
        self.repository = repository
        getTodosUseCase = GetTodosUseCase(repository: repository)
        getTodoByIdUseCase = GetTodoByIdUseCase(repository: repository)
        updateTodoUseCase = UpdateTodoUseCase(repository: repository)
        seedIfNeeded()
    }

    /// Builds the SwiftUI root view configured with dependencies.
    /// - Returns: A navigation stack displaying the todo list.
    func makeRootView() -> some View {
        NavigationStack {
            TodoListView(viewModel: makeTodoListViewModel())
                .navigationDestination(for: UUID.self) { identifier in
                    TodoDetailView(todoID: identifier, viewModel: makeTodoDetailViewModel())
                }
        }
    }

    private func makeTodoListViewModel() -> TodoListViewModel {
        TodoListViewModel(
            getTodosUseCase: getTodosUseCase,
            updateTodoUseCase: updateTodoUseCase
        )
    }

    private func makeTodoDetailViewModel() -> TodoDetailViewModel {
        TodoDetailViewModel(
            getTodoByIdUseCase: getTodoByIdUseCase,
            updateTodoUseCase: updateTodoUseCase
        )
    }

    private func seedIfNeeded() {
        do {
            let current = try dataSource.loadTodos()
            guard current.isEmpty else {
                return
            }
            let sample = SampleTodoFactory.makeSamples()
            try dataSource.saveTodos(sample)
        } catch {
            #if DEBUG
            print("Seed error: \(error)")
            #endif
        }
    }
}

private enum SampleTodoFactory {
    static func makeSamples() -> [TodoEntity] {
        [
            TodoEntity(
                id: UUID(),
                icon: "checklist",
                title: "Planificar sprint",
                details: "Revisar backlog y priorizar historias para el próximo sprint.",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                isCompleted: false
            ),
            TodoEntity(
                id: UUID(),
                icon: "cart",
                title: "Comprar víveres",
                details: "Leche, huevos, pan integral y frutas de temporada.",
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                isCompleted: false
            ),
            TodoEntity(
                id: UUID(),
                icon: "book.closed",
                title: "Leer capítulo de SwiftUI",
                details: "Repasar conceptos de navegación y estados en la guía oficial.",
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                isCompleted: true
            )
        ]
    }
}
