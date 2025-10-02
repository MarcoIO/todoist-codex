import Foundation

/// Manages the state of the task list screen with multiple lists and categories.
public final class TaskListViewModel: ObservableObject {
    @Published public private(set) var lists: [TaskList] = []
    @Published public var errorMessage: String?

    private let fetchTaskListsUseCase: FetchTaskListsUseCase
    private let addTaskListUseCase: AddTaskListUseCase
    private let deleteTaskListUseCase: DeleteTaskListUseCase
    private let addTaskUseCase: AddTaskToListUseCase
    private let updateTaskStatusUseCase: UpdateTaskStatusUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase

    public init(
        fetchTaskListsUseCase: FetchTaskListsUseCase,
        addTaskListUseCase: AddTaskListUseCase,
        deleteTaskListUseCase: DeleteTaskListUseCase,
        addTaskUseCase: AddTaskToListUseCase,
        updateTaskStatusUseCase: UpdateTaskStatusUseCase,
        deleteTaskUseCase: DeleteTaskUseCase
    ) {
        self.fetchTaskListsUseCase = fetchTaskListsUseCase
        self.addTaskListUseCase = addTaskListUseCase
        self.deleteTaskListUseCase = deleteTaskListUseCase
        self.addTaskUseCase = addTaskUseCase
        self.updateTaskStatusUseCase = updateTaskStatusUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
    }

    @MainActor
    public func loadLists() {
        do {
            lists = try fetchTaskListsUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func addList(name: String, category: TaskCategory) {
        let list = TaskList(name: name, category: category, tasks: [])
        do {
            try addTaskListUseCase.execute(list: list)
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func deleteLists(at offsets: IndexSet) {
        let identifiers = offsets.compactMap { index in
            lists.indices.contains(index) ? lists[index].id : nil
        }

        guard !identifiers.isEmpty else { return }

        do {
            for identifier in identifiers {
                try deleteTaskListUseCase.execute(identifier: identifier)
            }
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func delete(list: TaskList) {
        do {
            try deleteTaskListUseCase.execute(identifier: list.id)
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func addTask(
        to list: TaskList,
        iconName: String,
        title: String,
        details: String,
        dueDate: Date,
        category: TaskCategory
    ) {
        let task = Task(
            iconName: iconName,
            title: title,
            details: details,
            dueDate: dueDate,
            status: .pending,
            listID: list.id,
            listName: list.name,
            category: category
        )

        do {
            try addTaskUseCase.execute(task: task)
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func toggleStatus(for task: Task) {
        var updatedTask = task
        updatedTask.status = task.status == .completed ? .pending : .completed
        do {
            try updateTaskStatusUseCase.execute(task: updatedTask)
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func deleteTask(_ task: Task) {
        do {
            try deleteTaskUseCase.execute(identifier: task.id)
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func deleteTasks(in list: TaskList, at offsets: IndexSet) {
        let identifiers = offsets.compactMap { index in
            list.tasks.indices.contains(index) ? list.tasks[index].id : nil
        }

        guard !identifiers.isEmpty else { return }

        do {
            for identifier in identifiers {
                try deleteTaskUseCase.execute(identifier: identifier)
            }
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    private func message(for error: Error) -> String {
        if
            let localizedError = error as? LocalizedError,
            let description = localizedError.errorDescription,
            !description.isEmpty
        {
            return description
        }
        return NSLocalizedString("error_unknown", comment: "")
    }
}
