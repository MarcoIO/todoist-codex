import Foundation

/// Manages the state of the task list screen with multiple lists and categories.
public final class TaskListViewModel: ObservableObject {
    @Published public private(set) var lists: [TaskList] = []
    @Published public var errorMessage: String?

    private let fetchTaskListsUseCase: FetchTaskListsUseCase
    private let addTaskListUseCase: AddTaskListUseCase
    private let deleteTaskListUseCase: DeleteTaskListUseCase
    private let addTaskUseCase: AddTaskToListUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    private let updateTaskListUseCase: UpdateTaskListUseCase

    public init(
        fetchTaskListsUseCase: FetchTaskListsUseCase,
        addTaskListUseCase: AddTaskListUseCase,
        deleteTaskListUseCase: DeleteTaskListUseCase,
        addTaskUseCase: AddTaskToListUseCase,
        updateTaskUseCase: UpdateTaskUseCase,
        deleteTaskUseCase: DeleteTaskUseCase,
        updateTaskListUseCase: UpdateTaskListUseCase
    ) {
        self.fetchTaskListsUseCase = fetchTaskListsUseCase
        self.addTaskListUseCase = addTaskListUseCase
        self.deleteTaskListUseCase = deleteTaskListUseCase
        self.addTaskUseCase = addTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        self.updateTaskListUseCase = updateTaskListUseCase
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
        title: String,
        details: String,
        dueDate: Date,
        category: TaskCategory
    ) {
        let task = Task(
            iconName: Task.defaultIconName,
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
            try updateTaskUseCase.execute(task: updatedTask)
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func updateTask(
        _ task: Task,
        title: String,
        details: String,
        dueDate: Date,
        category: TaskCategory
    ) {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.details = details
        updatedTask.dueDate = dueDate
        updatedTask.category = category

        do {
            try updateTaskUseCase.execute(task: updatedTask)
            loadLists()
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func update(list: TaskList, name: String, category: TaskCategory) {
        var updatedList = list
        updatedList.name = name
        updatedList.category = category
        updatedList.tasks = updatedList.tasks.map { task in
            var mutableTask = task
            mutableTask.listName = name
            return mutableTask
        }

        do {
            try updateTaskListUseCase.execute(list: updatedList)
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
