import Foundation

extension TodoStatus {
    func localizedKey() -> String {
        switch self {
        case .pending:
            return "status.pending"
        case .inProgress:
            return "status.inProgress"
        case .completed:
            return "status.completed"
        }
    }
}
