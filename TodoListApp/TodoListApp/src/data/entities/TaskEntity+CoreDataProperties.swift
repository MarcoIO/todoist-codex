import CoreData
import Foundation

public extension TaskEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged var identifier: UUID
    @NSManaged var iconName: String
    @NSManaged var titleText: String
    @NSManaged var detailsText: String
    @NSManaged var dueDate: Date
    @NSManaged var statusRaw: String
}
