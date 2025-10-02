import SwiftUI

/// SwiftUI view displaying the details of a selected TODO item.
struct TodoDetailView: View {
    @StateObject private var viewModel: TodoDetailViewModel
    private let todoID: UUID

    /// Creates the detail view.
    /// - Parameters:
    ///   - todoID: Identifier of the todo item to display.
    ///   - viewModel: View model responsible for loading the item.
    init(todoID: UUID, viewModel: @autoclosure @escaping () -> TodoDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.todoID = todoID
    }

    var body: some View {
        content
            .navigationTitle("Detalle")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.load(id: todoID) }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Cargando detalle...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(data):
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: data.icon)
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(data.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Label {
                                Text(data.dueDate, style: .date)
                                    .font(.body)
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Descripción")
                            .font(.headline)
                        Text(data.details)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    Toggle(isOn: .constant(data.isCompleted)) {
                        Label("Completada", systemImage: "checkmark.circle")
                    }
                    .disabled(true)

                    Button {
                        viewModel.toggleCompletion()
                    } label: {
                        Label(
                            data.isCompleted ? "Marcar como pendiente" : "Marcar como completada",
                            systemImage: data.isCompleted ? "arrow.uturn.backward" : "checkmark"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        case let .failed(message):
            VStack(spacing: 12) {
                Image(systemName: "xmark.octagon")
                    .font(.system(size: 36))
                    .foregroundColor(.red)
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Button("Reintentar") {
                    viewModel.load(id: todoID)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#if DEBUG
private final class PreviewDetailTodoRepository: TodoRepository {
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

struct TodoDetailView_Previews: PreviewProvider {
    private static let sampleItem = TodoItem(
        id: UUID(),
        icon: "checkmark.seal",
        title: "Revisar pull requests",
        details: "Validar los comentarios pendientes y aprobar los cambios.",
        dueDate: Date(),
        isCompleted: false
    )

    static var previews: some View {
        let repository = PreviewDetailTodoRepository(items: [sampleItem])
        let viewModel = TodoDetailViewModel(
            getTodoByIdUseCase: GetTodoByIdUseCase(repository: repository),
            updateTodoUseCase: UpdateTodoUseCase(repository: repository)
        )
        return NavigationStack {
            TodoDetailView(todoID: sampleItem.id, viewModel: viewModel)
        }
    }
}
#endif
