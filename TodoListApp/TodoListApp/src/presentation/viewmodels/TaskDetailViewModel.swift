import Foundation

/// Exposes a single task for the detail screen.
public final class TaskDetailViewModel: ObservableObject {
    @Published public private(set) var task: Task?
    @Published public var errorMessage: String?

    private let taskIdentifier: UUID
    private let getTaskByIDUseCase: GetTaskByIDUseCase
    private let updateTaskStatusUseCase: UpdateTaskStatusUseCase

    public init(
        taskIdentifier: UUID,
        getTaskByIDUseCase: GetTaskByIDUseCase,
        updateTaskStatusUseCase: UpdateTaskStatusUseCase
    ) {
        self.taskIdentifier = taskIdentifier
        self.getTaskByIDUseCase = getTaskByIDUseCase
        self.updateTaskStatusUseCase = updateTaskStatusUseCase
    }

    @MainActor
    public func loadTask() {
        do {
            task = try getTaskByIDUseCase.execute(identifier: taskIdentifier)
        } catch {
            errorMessage = message(for: error)
        }
    }

    @MainActor
    public func toggleStatus() {
        guard var currentTask = task else { return }
        currentTask.status = currentTask.status == .completed ? .pending : .completed
        do {
            try updateTaskStatusUseCase.execute(task: currentTask)
            loadTask()
        } catch {
            errorMessage = message(for: error)
        }
    }

    private func message(for error: Error) -> String {
        if
            let localizedError = error as? LocalizedError,
            let description = localizedError.errorDescription,
            !description.isEmpty
        {
            return description
        }
        return NSLocalizedString("error_unknown", comment: "")
    }
}
