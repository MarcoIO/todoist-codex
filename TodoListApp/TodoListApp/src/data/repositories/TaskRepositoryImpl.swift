import Foundation

/// Concrete implementation of the task list repository backed by Core Data.
public final class TaskListRepositoryImpl: TaskListRepository {
    private let dataSource: CoreDataTaskListDataSource

    public init(dataSource: CoreDataTaskListDataSource) {
        self.dataSource = dataSource
        try? dataSource.ensureInitialData(using: Self.makeSampleData)
    }

    public func fetchLists() throws -> [TaskList] {
        try dataSource.fetchLists().compactMap(mapToDomain)
    }

    public func add(list: TaskList) throws {
        let model = mapToData(list: list)
        try dataSource.add(list: model)
    }

    public func deleteList(identifier: UUID) throws {
        try dataSource.deleteList(by: identifier)
    }

    public func add(task: Task) throws {
        let model = mapToData(task: task)
        try dataSource.add(task: model)
    }

    public func update(task: Task) throws {
        let model = mapToData(task: task)
        try dataSource.update(task: model)
    }

    public func deleteTask(identifier: UUID) throws {
        try dataSource.deleteTask(by: identifier)
    }

    public func getTask(by identifier: UUID) throws -> Task? {
        try dataSource.getTask(by: identifier).flatMap(mapToDomain(taskModel:))
    }

    private func mapToDomain(listModel: TaskListDataModel) -> TaskList? {
        guard let category = TaskCategory(rawValue: listModel.categoryRaw) else { return nil }
        let tasks = listModel.tasks.compactMap(mapToDomain(taskModel:)).sorted { $0.dueDate < $1.dueDate }
        return TaskList(
            id: listModel.identifier,
            name: listModel.name,
            category: category,
            tasks: tasks
        )
    }

    private func mapToDomain(taskModel: TaskDataModel) -> Task? {
        guard
            let status = TaskStatus(rawValue: taskModel.statusRaw),
            let category = TaskCategory(rawValue: taskModel.categoryRaw)
        else { return nil }

        return Task(
            id: taskModel.identifier,
            iconName: taskModel.iconName,
            title: taskModel.title,
            details: taskModel.details,
            dueDate: taskModel.dueDate,
            status: status,
            listID: taskModel.listIdentifier,
            listName: taskModel.listName,
            category: category
        )
    }

    private func mapToData(list: TaskList) -> TaskListDataModel {
        TaskListDataModel(
            identifier: list.id,
            name: list.name,
            categoryRaw: list.category.rawValue,
            tasks: list.tasks.map(mapToData(task:))
        )
    }

    private func mapToData(task: Task) -> TaskDataModel {
        TaskDataModel(
            identifier: task.id,
            iconName: task.iconName,
            title: task.title,
            details: task.details,
            dueDate: task.dueDate,
            statusRaw: task.status.rawValue,
            listIdentifier: task.listID,
            listName: task.listName,
            categoryRaw: task.category.rawValue
        )
    }

    private static func makeSampleData() -> [TaskListDataModel] {
        let today = Date()
        let calendar = Calendar.current
        let workTasks = [
            TaskDataModel(
                iconName: "list.bullet.clipboard",
                title: NSLocalizedString("sample_task_title_plan", comment: ""),
                details: NSLocalizedString("sample_task_details_plan", comment: ""),
                dueDate: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                statusRaw: TaskStatus.pending.rawValue,
                listIdentifier: UUID(),
                listName: NSLocalizedString("sample_list_work", comment: ""),
                categoryRaw: TaskCategory.work.rawValue
            ),
            TaskDataModel(
                iconName: "checkmark.circle.fill",
                title: NSLocalizedString("sample_task_title_review", comment: ""),
                details: NSLocalizedString("sample_task_details_review", comment: ""),
                dueDate: calendar.date(byAdding: .day, value: 3, to: today) ?? today,
                statusRaw: TaskStatus.completed.rawValue,
                listIdentifier: UUID(),
                listName: NSLocalizedString("sample_list_work", comment: ""),
                categoryRaw: TaskCategory.work.rawValue
            )
        ]

        let shoppingTasks = [
            TaskDataModel(
                iconName: "cart",
                title: NSLocalizedString("sample_task_title_buy", comment: ""),
                details: NSLocalizedString("sample_task_details_buy", comment: ""),
                dueDate: calendar.date(byAdding: .day, value: 2, to: today) ?? today,
                statusRaw: TaskStatus.pending.rawValue,
                listIdentifier: UUID(),
                listName: NSLocalizedString("sample_list_shopping", comment: ""),
                categoryRaw: TaskCategory.shopping.rawValue
            )
        ]

        let workListID = UUID()
        let shoppingListID = UUID()

        let remappedWorkTasks = workTasks.map { task -> TaskDataModel in
            TaskDataModel(
                identifier: task.identifier,
                iconName: task.iconName,
                title: task.title,
                details: task.details,
                dueDate: task.dueDate,
                statusRaw: task.statusRaw,
                listIdentifier: workListID,
                listName: NSLocalizedString("sample_list_work", comment: ""),
                categoryRaw: task.categoryRaw
            )
        }

        let remappedShoppingTasks = shoppingTasks.map { task -> TaskDataModel in
            TaskDataModel(
                identifier: task.identifier,
                iconName: task.iconName,
                title: task.title,
                details: task.details,
                dueDate: task.dueDate,
                statusRaw: task.statusRaw,
                listIdentifier: shoppingListID,
                listName: NSLocalizedString("sample_list_shopping", comment: ""),
                categoryRaw: task.categoryRaw
            )
        }

        return [
            TaskListDataModel(
                identifier: workListID,
                name: NSLocalizedString("sample_list_work", comment: ""),
                categoryRaw: TaskCategory.work.rawValue,
                tasks: remappedWorkTasks
            ),
            TaskListDataModel(
                identifier: shoppingListID,
                name: NSLocalizedString("sample_list_shopping", comment: ""),
                categoryRaw: TaskCategory.shopping.rawValue,
                tasks: remappedShoppingTasks
            )
        ]
    }
}
