import Foundation

/// Represents the completion state of a task in the domain layer.
public enum TaskStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case completed

    public var id: String { rawValue }

    /// Returns the localized key used to describe the status in the UI.
    public var localizationKey: String {
        switch self {
        case .pending:
            return "task_status_pending"
        case .completed:
            return "task_status_completed"
        }
    }
}
