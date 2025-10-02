import Foundation

/// Exposes a single task for the detail screen.
public final class TaskDetailViewModel: ObservableObject {
    @Published public private(set) var task: Task?
    @Published public var errorMessage: String?

    private let taskIdentifier: UUID
    private let getTaskByIDUseCase: GetTaskByIDUseCase
    private let updateTaskUseCase: UpdateTaskUseCase

    public init(
        taskIdentifier: UUID,
        getTaskByIDUseCase: GetTaskByIDUseCase,
        updateTaskUseCase: UpdateTaskUseCase
    ) {
        self.taskIdentifier = taskIdentifier
        self.getTaskByIDUseCase = getTaskByIDUseCase
        self.updateTaskUseCase = updateTaskUseCase
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
            try updateTaskUseCase.execute(task: currentTask)
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
