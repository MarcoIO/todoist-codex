import Foundation

/// Identifies the thematic grouping of a task list.
public enum TaskListCategory: String, Codable, CaseIterable, Identifiable {
    case work
    case personal
    case family
    case hobby
    case study

    public var id: String { rawValue }

    public var localizationKey: String {
        switch self {
        case .work:
            return "task_list_category_work"
        case .personal:
            return "task_list_category_personal"
        case .family:
            return "task_list_category_family"
        case .hobby:
            return "task_list_category_hobby"
        case .study:
            return "task_list_category_study"
        }
    }

    public var iconName: String {
        switch self {
        case .work:
            return "briefcase"
        case .personal:
            return "person"
        case .family:
            return "house"
        case .hobby:
            return "paintpalette"
        case .study:
            return "graduationcap"
        }
    }
}
