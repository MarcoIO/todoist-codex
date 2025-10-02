import SwiftUI

@main
struct TodoListAppApp: App {
    @StateObject private var languageController = LanguageController()
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            TaskListView(
                viewModel: dependencies.makeTaskListViewModel(),
                detailBuilder: { task in
                    TaskDetailView(
                        viewModel: dependencies.makeTaskDetailViewModel(for: task.id)
                    )
                }
            )
            .environmentObject(languageController)
            .environment(\.managedObjectContext, dependencies.persistenceController.container.viewContext)
            .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
        }
    }
}

private final class AppDependencies {
    let persistenceController: PersistenceController
    private let repository: TaskListRepository

    init() {
        persistenceController = PersistenceController()
        let dataSource = CoreDataTaskDataSource(context: persistenceController.container.viewContext)
        repository = TaskListRepositoryImpl(dataSource: dataSource)
    }

    func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(
            fetchTaskListsUseCase: FetchTaskListsUseCase(repository: repository),
            addTaskListUseCase: AddTaskListUseCase(repository: repository),
            deleteTaskListUseCase: DeleteTaskListUseCase(repository: repository),
            addTaskUseCase: AddTaskUseCase(repository: repository),
            updateTaskUseCase: UpdateTaskStatusUseCase(repository: repository),
            deleteTaskUseCase: DeleteTaskUseCase(repository: repository)
        )
    }

    func makeTaskDetailViewModel(for identifier: UUID) -> TaskDetailViewModel {
        TaskDetailViewModel(
            taskIdentifier: identifier,
            getTaskByIDUseCase: GetTaskByIDUseCase(repository: repository),
            updateTaskStatusUseCase: UpdateTaskStatusUseCase(repository: repository)
        )
    }
}
