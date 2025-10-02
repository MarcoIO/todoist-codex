import Foundation

/// Categorises a task for filtering and visual grouping.
public enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case planning
    case review
    case wellness
    case errands
    case learning

    public var id: String { rawValue }

    /// Human readable localization key for the category.
    public var localizationKey: String {
        switch self {
        case .planning:
            return "task_category_planning"
        case .review:
            return "task_category_review"
        case .wellness:
            return "task_category_wellness"
        case .errands:
            return "task_category_errands"
        case .learning:
            return "task_category_learning"
        }
    }

    /// System icon associated with the category.
    public var iconName: String {
        switch self {
        case .planning:
            return "calendar"
        case .review:
            return "checkmark.seal"
        case .wellness:
            return "heart"
        case .errands:
            return "cart"
        case .learning:
            return "book"
        }
    }
}
