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
            errorMessage = error.localizedDescription
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
            errorMessage = error.localizedDescription
        }
    }
}
