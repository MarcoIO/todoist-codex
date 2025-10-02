import Foundation

/// Defines localized errors produced by the Core Data data source.
enum TaskDataSourceError: LocalizedError {
    case listNotFound
    case taskNotFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .listNotFound:
            return NSLocalizedString("error_list_not_found", comment: "")
        case .taskNotFound:
            return NSLocalizedString("error_task_not_found", comment: "")
        case .unknown:
            return NSLocalizedString("error_unknown", comment: "")
        }
    }
}
