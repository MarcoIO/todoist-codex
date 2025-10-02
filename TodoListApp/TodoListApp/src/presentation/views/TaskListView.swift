import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var languageController: LanguageController
    @StateObject private var viewModel: TaskListViewModel

    @State private var isPresentingForm = false

    private let detailBuilder: (Task) -> TaskDetailView

    init(
        viewModel: TaskListViewModel,
        detailBuilder: @escaping (Task) -> TaskDetailView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.detailBuilder = detailBuilder
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.tasks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                        Text("empty_title")
                            .font(.headline)
                        Text("empty_description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.tasks) { task in
                            NavigationLink {
                                detailBuilder(task)
                            } label: {
                                TaskRowView(task: task)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    viewModel.toggleStatus(for: task)
                                } label: {
                                    Label(
                                        task.status == .completed ? "action_mark_pending" : "action_mark_completed",
                                        systemImage: task.status == .completed ? "arrow.uturn.left" : "checkmark"
                                    )
                                }
                                .tint(task.status == .completed ? .orange : .green)

                                Button(role: .destructive) {
                                    viewModel.delete(task: task)
                                } label: {
                                    Label("action_delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete { offsets in
                            viewModel.deleteTasks(at: offsets)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(Text("list_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("language_picker", selection: Binding(
                            get: { languageController.currentLanguage },
                            set: { languageController.updateLanguage($0) }
                        )) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayNameKey).tag(language)
                            }
                        }
                    } label: {
                        Label("language_menu", systemImage: "globe")
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                    Button {
                        isPresentingForm = true
                    } label: {
                        Label("action_add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingForm) {
                TaskFormView { icon, title, details, date in
                    viewModel.addTask(
                        iconName: icon,
                        title: title,
                        details: details,
                        dueDate: date
                    )
                }
                .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
            }
            .onAppear {
                viewModel.loadTasks()
            }
            .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
            .alert(isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("error_title"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("action_accept"))
                )
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        let persistence = PersistenceController(inMemory: true)
        let repository = TaskRepositoryImpl(dataSource: CoreDataTaskDataSource(context: persistence.container.viewContext))
        let fetch = FetchTasksUseCase(repository: repository)
        let add = AddTaskUseCase(repository: repository)
        let update = UpdateTaskStatusUseCase(repository: repository)
        let delete = DeleteTaskUseCase(repository: repository)
        let get = GetTaskByIDUseCase(repository: repository)
        let listViewModel = TaskListViewModel(
            fetchTasksUseCase: fetch,
            addTaskUseCase: add,
            updateTaskStatusUseCase: update,
            deleteTaskUseCase: delete
        )
        listViewModel.loadTasks()

        return TaskListView(viewModel: listViewModel) { task in
            TaskDetailView(
                viewModel: TaskDetailViewModel(
                    taskIdentifier: task.id,
                    getTaskByIDUseCase: get,
                    updateTaskStatusUseCase: update
                )
            )
        }
        .environmentObject(LanguageController())
    }
}
