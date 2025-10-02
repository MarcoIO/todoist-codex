import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var languageController: LanguageController
    @StateObject private var viewModel: TaskListViewModel

    @State private var isPresentingTaskForm = false
    @State private var isPresentingListForm = false
    @State private var selectedListForTask: TaskList?
    @State private var editingTask: Task?
    @State private var editingList: TaskList?

    private let detailBuilder: (Task) -> TaskDetailView

    init(
        viewModel: TaskListViewModel,
        detailBuilder: @escaping (Task) -> TaskDetailView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.detailBuilder = detailBuilder
    }

    private var categories: [TaskCategory] {
        TaskCategory.allCases
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.lists.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                        Text("empty_lists_title")
                            .font(.headline)
                        Text("empty_lists_description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(Array(viewModel.lists.enumerated()), id: \.element.id) { _, list in
                            Section {
                                ForEach(list.tasks) { task in
                                    NavigationLink {
                                        detailBuilder(task)
                                    } label: {
                                        TaskRowView(task: task)
                                            .contextMenu {
                                                Button(action: {
                                                    viewModel.toggleStatus(for: task)
                                                }) {
                                                    Label(
                                                        task.status == .completed ? "action_mark_pending" : "action_mark_completed",
                                                        systemImage: task.status == .completed ? "arrow.uturn.left" : "checkmark"
                                                    )
                                                }

                                                Button(action: {
                                                    editingTask = task
                                                }) {
                                                    Label("action_edit", systemImage: "pencil")
                                                }

                                                Button(role: .destructive, action: {
                                                    viewModel.deleteTask(task)
                                                }) {
                                                    Label("action_delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                    .listRowBackground(Color.clear)
                                }
                                .onDelete { offsets in
                                    viewModel.deleteTasks(in: list, at: offsets)
                                }

                                Button {
                                    selectedListForTask = list
                                    isPresentingTaskForm = true
                                } label: {
                                    Label("action_add_task", systemImage: "plus.circle")
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Image(systemName: list.category.iconName)
                                        .foregroundColor(.accentColor)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(list.name)
                                            .font(.headline)
                                        Text(LocalizedStringKey(list.category.localizationKey))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(String(format: NSLocalizedString("list_tasks_count_format", comment: ""), list.tasks.count))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .textCase(nil)
                                .contextMenu {
                                    Button {
                                        editingList = list
                                    } label: {
                                        Label("action_edit", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        viewModel.delete(list: list)
                                    } label: {
                                        Label("action_delete_list", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .onDelete { offsets in
                            viewModel.deleteLists(at: offsets)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle(Text("lists_title"))
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
                        isPresentingListForm = true
                    } label: {
                        Label("action_add_list", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingTaskForm) {
                if let list = selectedListForTask {
                    TaskFormView(
                        listName: list.name,
                        categories: categories
                    ) { title, details, date, category in
                        viewModel.addTask(
                            to: list,
                            title: title,
                            details: details,
                            dueDate: date,
                            category: category
                        )
                    }
                    .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
                    .onDisappear {
                        selectedListForTask = nil
                    }
                }
            }
            .sheet(isPresented: $isPresentingListForm) {
                TaskListFormView(categories: categories) { name, category in
                    viewModel.addList(name: name, category: category)
                }
                .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(
                    listName: task.listName,
                    categories: categories,
                    initialTask: task
                ) { title, details, date, category in
                    viewModel.updateTask(
                        task,
                        title: title,
                        details: details,
                        dueDate: date,
                        category: category
                    )
                }
                .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
            }
            .sheet(item: $editingList) { list in
                TaskListFormView(
                    categories: categories,
                    initialList: list
                ) { name, category in
                    viewModel.update(list: list, name: name, category: category)
                }
                .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
            }
            .onAppear {
                viewModel.loadLists()
                selectedListForTask = viewModel.lists.first
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        let persistence = PersistenceController(inMemory: true)
        let repository = TaskListRepositoryImpl(dataSource: CoreDataTaskListDataSource(context: persistence.container.viewContext))
        let fetch = FetchTaskListsUseCase(repository: repository)
        let addList = AddTaskListUseCase(repository: repository)
        let deleteList = DeleteTaskListUseCase(repository: repository)
        let addTask = AddTaskToListUseCase(repository: repository)
        let updateTask = UpdateTaskUseCase(repository: repository)
        let updateList = UpdateTaskListUseCase(repository: repository)
        let delete = DeleteTaskUseCase(repository: repository)
        let get = GetTaskByIDUseCase(repository: repository)
        let listViewModel = TaskListViewModel(
            fetchTaskListsUseCase: fetch,
            addTaskListUseCase: addList,
            deleteTaskListUseCase: deleteList,
            addTaskUseCase: addTask,
            updateTaskUseCase: updateTask,
            deleteTaskUseCase: delete,
            updateTaskListUseCase: updateList
        )
        listViewModel.loadLists()

        return TaskListView(viewModel: listViewModel) { task in
            TaskDetailView(
                viewModel: TaskDetailViewModel(
                    taskIdentifier: task.id,
                    getTaskByIDUseCase: get,
                    updateTaskUseCase: updateTask
                )
            )
        }
        .environmentObject(LanguageController())
    }
}
