import Foundation

/// Concrete implementation of the task list repository backed by Core Data.
public final class TaskListRepositoryImpl: TaskListRepository {
    private let dataSource: CoreDataTaskDataSource

    public init(dataSource: CoreDataTaskDataSource) {
        self.dataSource = dataSource
        try? dataSource.ensureInitialData(using: Self.makeSampleData)
    }

    public func fetchLists() throws -> [TaskList] {
        try dataSource.fetchTaskLists().compactMap(mapToDomain)
    }

    public func add(list: TaskList) throws {
        let model = mapToData(list: list)
        try dataSource.add(list: model)
    }

    public func update(list: TaskList) throws {
        let model = mapToData(list: list)
        try dataSource.update(list: model)
    }

    public func deleteList(identifier: UUID) throws {
        try dataSource.deleteList(by: identifier)
    }

    public func getTask(by identifier: UUID) throws -> Task? {
        try dataSource.getTask(by: identifier).flatMap(mapToDomain)
    }

    public func add(task: Task, to listID: UUID) throws {
        let model = mapToData(task: task, listID: listID)
        try dataSource.add(task: model)
    }

    public func update(task: Task) throws {
        let model = mapToData(task: task, listID: task.listID)
        try dataSource.update(task: model)
    }

    public func deleteTask(identifier: UUID) throws {
        try dataSource.deleteTask(by: identifier)
    }

    private func mapToDomain(model: TaskListDataModel) -> TaskList? {
        guard let category = TaskListCategory(rawValue: model.categoryRaw) else { return nil }
        let tasks = model.tasks.compactMap(mapToDomain)
        return TaskList(
            id: model.identifier,
            name: model.name,
            category: category,
            tasks: tasks
        )
    }

    private func mapToDomain(model: TaskDataModel) -> Task? {
        guard
            let status = TaskStatus(rawValue: model.statusRaw),
            let category = TaskCategory(rawValue: model.categoryRaw)
        else { return nil }

        return Task(
            id: model.identifier,
            listID: model.listIdentifier,
            iconName: model.iconName,
            title: model.title,
            details: model.details,
            dueDate: model.dueDate,
            status: status,
            category: category
        )
    }

    private func mapToData(list: TaskList) -> TaskListDataModel {
        TaskListDataModel(
            identifier: list.id,
            name: list.name,
            categoryRaw: list.category.rawValue,
            tasks: list.tasks.map { mapToData(task: $0, listID: list.id) }
        )
    }

    private func mapToData(task: Task, listID: UUID) -> TaskDataModel {
        TaskDataModel(
            identifier: task.id,
            listIdentifier: listID,
            iconName: task.iconName,
            title: task.title,
            details: task.details,
            dueDate: task.dueDate,
            statusRaw: task.status.rawValue,
            categoryRaw: task.category.rawValue
        )
    }

    private static func makeSampleData() -> [TaskListDataModel] {
        let today = Date()
        let workList = TaskListDataModel(
            name: NSLocalizedString("sample_list_work", comment: ""),
            categoryRaw: TaskListCategory.work.rawValue,
            tasks: [
                TaskDataModel(
                    listIdentifier: UUID(),
                    iconName: "tray.full",
                    title: NSLocalizedString("sample_task_title_plan", comment: ""),
                    details: NSLocalizedString("sample_task_details_plan", comment: ""),
                    dueDate: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today,
                    statusRaw: TaskStatus.pending.rawValue,
                    categoryRaw: TaskCategory.planning.rawValue
                ),
                TaskDataModel(
                    listIdentifier: UUID(),
                    iconName: "checkmark.circle.fill",
                    title: NSLocalizedString("sample_task_title_review", comment: ""),
                    details: NSLocalizedString("sample_task_details_review", comment: ""),
                    dueDate: Calendar.current.date(byAdding: .day, value: 3, to: today) ?? today,
                    statusRaw: TaskStatus.completed.rawValue,
                    categoryRaw: TaskCategory.review.rawValue
                )
            ]
        )

        let personalList = TaskListDataModel(
            name: NSLocalizedString("sample_list_personal", comment: ""),
            categoryRaw: TaskListCategory.personal.rawValue,
            tasks: [
                TaskDataModel(
                    listIdentifier: UUID(),
                    iconName: "star",
                    title: NSLocalizedString("sample_task_title_relax", comment: ""),
                    details: NSLocalizedString("sample_task_details_relax", comment: ""),
                    dueDate: Calendar.current.date(byAdding: .day, value: 2, to: today) ?? today,
                    statusRaw: TaskStatus.pending.rawValue,
                    categoryRaw: TaskCategory.wellness.rawValue
                )
            ]
        )

        func assignListID(_ list: TaskListDataModel) -> TaskListDataModel {
            var updatedList = list
            updatedList.tasks = list.tasks.map { task in
                TaskDataModel(
                    identifier: task.identifier,
                    listIdentifier: list.identifier,
                    iconName: task.iconName,
                    title: task.title,
                    details: task.details,
                    dueDate: task.dueDate,
                    statusRaw: task.statusRaw,
                    categoryRaw: task.categoryRaw
                )
            }
            return updatedList
        }

        return [assignListID(workList), assignListID(personalList)]
    }
}
