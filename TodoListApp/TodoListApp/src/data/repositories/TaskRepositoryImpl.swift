import Foundation

/// Concrete implementation of the task repository backed by Core Data.
public final class TaskRepositoryImpl: TaskRepository {
    private let dataSource: CoreDataTaskDataSource

    public init(dataSource: CoreDataTaskDataSource) {
        self.dataSource = dataSource
        try? dataSource.ensureInitialData(using: Self.makeSampleData)
    }

    public func fetchTasks() throws -> [Task] {
        try dataSource.fetchTasks().compactMap(mapToDomain)
    }

    public func getTask(by identifier: UUID) throws -> Task? {
        try dataSource.getTask(by: identifier).flatMap(mapToDomain)
    }

    public func add(task: Task) throws {
        let model = mapToData(task: task)
        try dataSource.add(task: model)
    }

    public func update(task: Task) throws {
        let model = mapToData(task: task)
        try dataSource.update(task: model)
    }

    public func delete(identifier: UUID) throws {
        try dataSource.deleteTask(by: identifier)
    }

    private func mapToDomain(model: TaskDataModel) -> Task? {
        guard let status = TaskStatus(rawValue: model.statusRaw) else { return nil }
        return Task(
            id: model.identifier,
            iconName: model.iconName,
            title: model.title,
            details: model.details,
            dueDate: model.dueDate,
            status: status
        )
    }

    private func mapToData(task: Task) -> TaskDataModel {
        TaskDataModel(
            identifier: task.id,
            iconName: task.iconName,
            title: task.title,
            details: task.details,
            dueDate: task.dueDate,
            statusRaw: task.status.rawValue
        )
    }

    private static func makeSampleData() -> [TaskDataModel] {
        [
            TaskDataModel(
                iconName: "list.bullet.clipboard",
                title: NSLocalizedString("sample_task_title_plan", comment: ""),
                details: NSLocalizedString("sample_task_details_plan", comment: ""),
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                statusRaw: TaskStatus.pending.rawValue
            ),
            TaskDataModel(
                iconName: "checkmark.circle.fill",
                title: NSLocalizedString("sample_task_title_review", comment: ""),
                details: NSLocalizedString("sample_task_details_review", comment: ""),
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                statusRaw: TaskStatus.completed.rawValue
            )
        ]
    }
}
