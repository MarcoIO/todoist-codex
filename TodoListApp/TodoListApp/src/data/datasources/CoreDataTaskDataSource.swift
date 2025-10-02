import CoreData
import Foundation

/// Provides CRUD operations backed by Core Data.
public final class CoreDataTaskDataSource {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func fetchTasks() throws -> [TaskDataModel] {
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)]
        let entities = try context.fetch(request)
        return entities.map(TaskDataModel.init(entity:))
    }

    public func getTask(by identifier: UUID) throws -> TaskDataModel? {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first.map(TaskDataModel.init(entity:))
    }

    public func add(task: TaskDataModel) throws {
        let entity = TaskEntity(context: context)
        entity.update(from: task)
        try context.save()
    }

    public func update(task: TaskDataModel) throws {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", task.identifier as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "TaskEntity", code: 0, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
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

    public func ensureInitialData(using factory: () -> [TaskDataModel]) throws {
        let request = TaskEntity.fetchRequest()
        let count = try context.count(for: request)
        guard count == 0 else { return }

        factory().forEach { model in
            let entity = TaskEntity(context: context)
            entity.update(from: model)
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
            statusRaw: entity.statusRaw ?? ""
        )
    }
}
