import Foundation

/// Manages the state of the task list screen.
public final class TaskListViewModel: ObservableObject {
    @Published public private(set) var tasks: [Task] = []
    @Published public var errorMessage: String?

    private let fetchTasksUseCase: FetchTasksUseCase
    private let addTaskUseCase: AddTaskUseCase
    private let updateTaskStatusUseCase: UpdateTaskStatusUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase

    public init(
        fetchTasksUseCase: FetchTasksUseCase,
        addTaskUseCase: AddTaskUseCase,
        updateTaskStatusUseCase: UpdateTaskStatusUseCase,
        deleteTaskUseCase: DeleteTaskUseCase
    ) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.addTaskUseCase = addTaskUseCase
        self.updateTaskStatusUseCase = updateTaskStatusUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
    }

    @MainActor
    public func loadTasks() {
        do {
            tasks = try fetchTasksUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func toggleStatus(for task: Task) {
        var updatedTask = task
        updatedTask.status = task.status == .completed ? .pending : .completed
        do {
            try updateTaskStatusUseCase.execute(task: updatedTask)
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func addTask(
        iconName: String,
        title: String,
        details: String,
        dueDate: Date
    ) {
        let task = Task(
            iconName: iconName,
            title: title,
            details: details,
            dueDate: dueDate,
            status: .pending
        )

        do {
            try addTaskUseCase.execute(task: task)
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func deleteTasks(at offsets: IndexSet) {
        let identifiers = offsets.compactMap { index in
            tasks.indices.contains(index) ? tasks[index].id : nil
        }

        guard !identifiers.isEmpty else { return }

        do {
            for identifier in identifiers {
                try deleteTaskUseCase.execute(identifier: identifier)
            }
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func delete(task: Task) {
        do {
            try deleteTaskUseCase.execute(identifier: task.id)
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
