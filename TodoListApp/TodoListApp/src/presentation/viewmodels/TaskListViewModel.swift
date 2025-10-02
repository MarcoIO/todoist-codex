import Foundation

/// Manages the state of the task lists screen.
public final class TaskListViewModel: ObservableObject {
    @Published public private(set) var lists: [TaskList] = []
    @Published public var errorMessage: String?

    private let fetchTaskListsUseCase: FetchTaskListsUseCase
    private let addTaskListUseCase: AddTaskListUseCase
    private let deleteTaskListUseCase: DeleteTaskListUseCase
    private let addTaskUseCase: AddTaskUseCase
    private let updateTaskUseCase: UpdateTaskStatusUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase

    public init(
        fetchTaskListsUseCase: FetchTaskListsUseCase,
        addTaskListUseCase: AddTaskListUseCase,
        deleteTaskListUseCase: DeleteTaskListUseCase,
        addTaskUseCase: AddTaskUseCase,
        updateTaskUseCase: UpdateTaskStatusUseCase,
        deleteTaskUseCase: DeleteTaskUseCase
    ) {
        self.fetchTaskListsUseCase = fetchTaskListsUseCase
        self.addTaskListUseCase = addTaskListUseCase
        self.deleteTaskListUseCase = deleteTaskListUseCase
        self.addTaskUseCase = addTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
    }

    @MainActor
    public func loadData() {
        do {
            lists = try fetchTaskListsUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func addList(name: String, category: TaskListCategory) {
        let list = TaskList(name: name, category: category)
        do {
            try addTaskListUseCase.execute(list: list)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func deleteLists(at offsets: IndexSet) {
        let identifiers = offsets.compactMap { index -> UUID? in
            guard lists.indices.contains(index) else { return nil }
            return lists[index].id
        }

        guard !identifiers.isEmpty else { return }

        do {
            for identifier in identifiers {
                try deleteTaskListUseCase.execute(identifier: identifier)
            }
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func addTask(
        in list: TaskList,
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        category: TaskCategory
    ) {
        let task = Task(
            listID: list.id,
            iconName: iconName,
            title: title,
            details: details,
            dueDate: dueDate,
            status: .pending,
            category: category
        )

        do {
            try addTaskUseCase.execute(task: task, listID: list.id)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func toggleStatus(for task: Task) {
        var updatedTask = task
        updatedTask.status = task.status == .completed ? .pending : .completed
        do {
            try updateTaskUseCase.execute(task: updatedTask)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func deleteTasks(in list: TaskList, at offsets: IndexSet) {
        let identifiers = offsets.compactMap { index -> UUID? in
            guard list.tasks.indices.contains(index) else { return nil }
            return list.tasks[index].id
        }

        guard !identifiers.isEmpty else { return }

        do {
            for identifier in identifiers {
                try deleteTaskUseCase.execute(identifier: identifier)
            }
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func delete(task: Task) {
        do {
            try deleteTaskUseCase.execute(identifier: task.id)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
