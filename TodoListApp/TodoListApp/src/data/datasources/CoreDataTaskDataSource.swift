import CoreData
import Foundation

/// Provides CRUD operations for task lists and tasks backed by Core Data.
public final class CoreDataTaskDataSource {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func fetchTaskLists() throws -> [TaskListDataModel] {
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
        let request = TaskListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", list.identifier as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "TaskListEntity", code: 0, userInfo: [NSLocalizedDescriptionKey: "List not found"])
        }
        entity.update(from: list)
        try context.save()
    }

    public func deleteList(by identifier: UUID) throws {
        let request = TaskListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "TaskListEntity", code: 1, userInfo: [NSLocalizedDescriptionKey: "List not found"])
        }
        context.delete(entity)
        try context.save()
    }

    public func add(task: TaskDataModel) throws {
        let listRequest = TaskListEntity.fetchRequest()
        listRequest.predicate = NSPredicate(format: "identifier == %@", task.listIdentifier as CVarArg)
        listRequest.fetchLimit = 1
        guard let listEntity = try context.fetch(listRequest).first else {
            throw NSError(domain: "TaskListEntity", code: 2, userInfo: [NSLocalizedDescriptionKey: "List not found"])
        }

        let entity = TaskEntity(context: context)
        entity.update(from: task)
        entity.list = listEntity
        try context.save()
    }

    public func update(task: TaskDataModel) throws {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", task.identifier as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "TaskEntity", code: 0, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
        }

        if entity.list?.identifier != task.listIdentifier {
            let listRequest = TaskListEntity.fetchRequest()
            listRequest.predicate = NSPredicate(format: "identifier == %@", task.listIdentifier as CVarArg)
            listRequest.fetchLimit = 1
            entity.list = try context.fetch(listRequest).first
        }

        entity.update(from: task)
        try context.save()
    }

    public func deleteTask(by identifier: UUID) throws {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "TaskEntity", code: 1, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
        }
        context.delete(entity)
        try context.save()
    }

    public func ensureInitialData(using factory: () -> [TaskListDataModel]) throws {
        let request = TaskListEntity.fetchRequest()
        let count = try context.count(for: request)
        guard count == 0 else { return }

        factory().forEach { model in
            let listEntity = TaskListEntity(context: context)
            listEntity.update(from: model)

            model.tasks.forEach { taskModel in
                let taskEntity = TaskEntity(context: context)
                taskEntity.update(from: taskModel)
                taskEntity.list = listEntity
            }
        }

        try context.save()
    }
}

private extension TaskEntity {
    func update(from model: TaskDataModel) {
        identifier = model.identifier
        iconName = model.iconName
        titleText = model.title
        detailsText = model.details
        dueDate = model.dueDate
        statusRaw = model.statusRaw
        categoryRaw = model.categoryRaw
    }
}

private extension TaskDataModel {
    init(entity: TaskEntity) {
        self.init(
            identifier: entity.identifier ?? UUID(),
            listIdentifier: entity.list?.identifier ?? UUID(),
            iconName: entity.iconName ?? "",
            title: entity.titleText ?? "",
            details: entity.detailsText ?? "",
            dueDate: entity.dueDate ?? Date(),
            statusRaw: entity.statusRaw ?? "",
            categoryRaw: entity.categoryRaw ?? ""
        )
    }
}

private extension TaskListEntity {
    func update(from model: TaskListDataModel) {
        identifier = model.identifier
        name = model.name
        categoryRaw = model.categoryRaw
    }
}

private extension TaskListDataModel {
    init(entity: TaskListEntity) {
        self.init(
            identifier: entity.identifier ?? UUID(),
            name: entity.name ?? "",
            categoryRaw: entity.categoryRaw ?? "",
            tasks: (entity.tasks as? Set<TaskEntity> ?? []).sorted { lhs, rhs in
                (lhs.dueDate ?? Date()) < (rhs.dueDate ?? Date())
            }.map(TaskDataModel.init(entity:))
        )
    }
}
