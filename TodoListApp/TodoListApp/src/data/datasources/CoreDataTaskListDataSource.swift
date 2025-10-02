import CoreData
import Foundation

/// Provides CRUD operations for lists and tasks backed by Core Data.
public final class CoreDataTaskListDataSource {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func fetchLists() throws -> [TaskListDataModel] {
        let request = TaskListEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskListEntity.name, ascending: true)]
        let entities = try context.fetch(request)
        return entities.map(TaskListDataModel.init(entity:))
    }

    public func getTask(by identifier: UUID) throws -> TaskDataModel? {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first.map(TaskDataModel.init(entity:))
    }

    public func add(list: TaskListDataModel) throws {
        let entity = TaskListEntity(context: context)
        entity.update(from: list)
        try context.save()
    }

    public func update(list: TaskListDataModel) throws {
        guard let entity = try fetchListEntity(identifier: list.identifier) else {
            throw TaskDataSourceError.listNotFound
        }
        entity.update(from: list)
        try context.save()
    }

    public func deleteList(by identifier: UUID) throws {
        guard let entity = try fetchListEntity(identifier: identifier) else {
            throw TaskDataSourceError.listNotFound
        }
        context.delete(entity)
        try context.save()
    }

    public func add(task: TaskDataModel) throws {
        guard let listEntity = try fetchListEntity(identifier: task.listIdentifier) else {
            throw TaskDataSourceError.listNotFound
        }
        let entity = TaskEntity(context: context)
        entity.update(from: task, listEntity: listEntity)
        try context.save()
    }

    public func update(task: TaskDataModel) throws {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", task.identifier as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw TaskDataSourceError.taskNotFound
        }
        guard let listEntity = try fetchListEntity(identifier: task.listIdentifier) else {
            throw TaskDataSourceError.listNotFound
        }
        entity.update(from: task, listEntity: listEntity)
        try context.save()
    }

    public func deleteTask(by identifier: UUID) throws {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw TaskDataSourceError.taskNotFound
        }
        context.delete(entity)
        try context.save()
    }

    public func ensureInitialData(using factory: () -> [TaskListDataModel]) throws {
        let request = TaskListEntity.fetchRequest()
        let count = try context.count(for: request)
        guard count == 0 else { return }

        factory().forEach { listModel in
            let listEntity = TaskListEntity(context: context)
            listEntity.update(from: listModel)
            listModel.tasks.forEach { taskModel in
                let taskEntity = TaskEntity(context: context)
                taskEntity.update(from: taskModel, listEntity: listEntity)
            }
        }

        try context.save()
    }

    private func fetchListEntity(identifier: UUID) throws -> TaskListEntity? {
        let request = TaskListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

private extension TaskListEntity {
    func update(from model: TaskListDataModel) {
        identifier = model.identifier
        name = model.name
        categoryRaw = model.categoryRaw
    }
}

private extension TaskEntity {
    func update(from model: TaskDataModel, listEntity: TaskListEntity) {
        identifier = model.identifier
        iconName = model.iconName
        titleText = model.title
        detailsText = model.details
        dueDate = model.dueDate
        statusRaw = model.statusRaw
        categoryRaw = model.categoryRaw
        list = listEntity
    }
}

private extension TaskListDataModel {
    init(entity: TaskListEntity) {
        self.init(
            identifier: entity.identifier ?? UUID(),
            name: entity.name ?? "",
            categoryRaw: entity.categoryRaw ?? "",
            tasks: (entity.tasks as? Set<TaskEntity> ?? []).map(TaskDataModel.init(entity:))
        )
    }
}

private extension TaskDataModel {
    init(entity: TaskEntity) {
        self.init(
            identifier: entity.identifier ?? UUID(),
            iconName: entity.iconName ?? "",
            title: entity.titleText ?? "",
            details: entity.detailsText ?? "",
            dueDate: entity.dueDate ?? Date(),
            statusRaw: entity.statusRaw ?? "",
            listIdentifier: entity.list?.identifier ?? UUID(),
            listName: entity.list?.name ?? "",
            categoryRaw: entity.categoryRaw ?? ""
        )
    }
}
