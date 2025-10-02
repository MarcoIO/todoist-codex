import SwiftUI

/// SwiftUI view that renders the todo list and handles navigation to detail.
struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel

    /// Creates the list view injecting its dependencies.
    /// - Parameter viewModel: View model managing the todo list state.
    init(viewModel: @autoclosure @escaping () -> TodoListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        content
            .navigationTitle("Mis tareas")
            .onAppear(perform: viewModel.load)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Cargando tareas...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(items):
            List(items) { item in
                NavigationLink(value: item.id) {
                    TodoRowView(item: item)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        viewModel.toggleCompletion(for: item)
                    } label: {
                        Label(
                            item.isCompleted ? "Reabrir" : "Completar",
                            systemImage: item.isCompleted ? "arrow.uturn.backward" : "checkmark"
                        )
                    }
                    .tint(item.isCompleted ? .orange : .green)
                }
            }
            .listStyle(.insetGrouped)
        case let .failed(message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                Button("Reintentar", action: viewModel.load)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct TodoRowView: View {
    let item: TodoListItemViewData

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 24))
                .foregroundColor(item.isCompleted ? .gray : .accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(item.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if item.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
private final class PreviewTodoRepository: TodoRepository {
    private var items: [TodoItem]

    init(items: [TodoItem]) {
        self.items = items
    }

    func fetchTodos() throws -> [TodoItem] {
        items
    }

    func fetchTodo(id: UUID) throws -> TodoItem? {
        items.first { $0.id == id }
    }

    func create(todo: TodoItem) throws {
        items.append(todo)
    }

    func update(todo: TodoItem) throws {
        guard let index = items.firstIndex(where: { $0.id == todo.id }) else {
            return
        }
        items[index] = todo
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        let previewItems = [
            TodoItem(
                id: UUID(),
                icon: "checklist",
                title: "Revisar informes",
                details: "Analizar métricas de satisfacción",
                dueDate: Date(),
                isCompleted: false
            ),
            TodoItem(
                id: UUID(),
                icon: "cart",
                title: "Comprar víveres",
                details: "Frutas, verduras y pan",
                dueDate: Date(),
                isCompleted: true
            )
        ]
        let repository = PreviewTodoRepository(items: previewItems)
        let viewModel = TodoListViewModel(
            getTodosUseCase: GetTodosUseCase(repository: repository),
            updateTodoUseCase: UpdateTodoUseCase(repository: repository)
        )
        return NavigationStack {
            TodoListView(viewModel: viewModel)
        }
    }
}
#endif
