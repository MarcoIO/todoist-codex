import Foundation

/// Represents a type of task or list category in the domain layer.
public enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case work
    case shopping
    case leisure
    case personal
    case health
    case errands

    public var id: String { rawValue }

    /// Human readable localization key for the category.
    public var localizationKey: String {
        switch self {
        case .work:
            return "category_work"
        case .shopping:
            return "category_shopping"
        case .leisure:
            return "category_leisure"
        case .personal:
            return "category_personal"
        case .health:
            return "category_health"
        case .errands:
            return "category_errands"
        }
    }

    /// SF Symbol associated with the category.
    public var iconName: String {
        switch self {
        case .work:
            return "briefcase.fill"
        case .shopping:
            return "cart.fill"
        case .leisure:
            return "gamecontroller.fill"
        case .personal:
            return "person.crop.circle.fill"
        case .health:
            return "heart.fill"
        case .errands:
            return "checklist"
        }
    }
}
