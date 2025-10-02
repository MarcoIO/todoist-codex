import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var languageController: LanguageController
    @StateObject private var viewModel: TaskListViewModel

    @State private var isPresentingTaskForm = false
    @State private var isPresentingListForm = false
    @State private var selectedListForTask: TaskList?

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
                    VStack(spacing: 12) {
                        Text("empty_lists_title")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("empty_lists_description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(Array(viewModel.lists.enumerated()), id: \.element.id) { _, list in
                            Section(header: header(for: list)) {
                                ForEach(list.tasks) { task in
                                    NavigationLink {
                                        detailBuilder(task)
                                    } label: {
                                        TaskRowView(task: task)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 16)
                                    }
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                    .contextMenu {
                                        Button(action: {
                                            viewModel.toggleStatus(for: task)
                                        }) {
                                            Label(
                                                task.status == .completed ? "action_mark_pending" : "action_mark_completed",
                                                systemImage: task.status == .completed ? "arrow.uturn.left" : "checkmark"
                                            )
                                        }

                                        Button(role: .destructive, action: {
                                            viewModel.deleteTask(task)
                                        }) {
                                            Label("action_delete", systemImage: "trash")
                                        }
                                    }
                                }
                                .onDelete { offsets in
                                    viewModel.deleteTasks(in: list, at: offsets)
                                }

                                Button {
                                    selectedListForTask = list
                                    isPresentingTaskForm = true
                                } label: {
                                    HStack {
                                        Text("action_add_task")
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color(.secondarySystemBackground))
                                    )
                                }
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                .listRowBackground(Color.clear)
                            }
                        }
                        .onDelete { offsets in
                            viewModel.deleteLists(at: offsets)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(.systemGroupedBackground))
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
                    ) { icon, title, details, date, category in
                        viewModel.addTask(
                            to: list,
                            iconName: icon,
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

private extension TaskListView {
    func header(for list: TaskList) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(list.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(String(format: NSLocalizedString("list_tasks_count_format", comment: ""), list.tasks.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(LocalizedStringKey(list.category.localizationKey))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .textCase(nil)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.delete(list: list)
            } label: {
                Label("action_delete_list", systemImage: "trash")
            }
        }
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
        let update = UpdateTaskStatusUseCase(repository: repository)
        let delete = DeleteTaskUseCase(repository: repository)
        let get = GetTaskByIDUseCase(repository: repository)
        let listViewModel = TaskListViewModel(
            fetchTaskListsUseCase: fetch,
            addTaskListUseCase: addList,
            deleteTaskListUseCase: deleteList,
            addTaskUseCase: addTask,
            updateTaskStatusUseCase: update,
            deleteTaskUseCase: delete
        )
        listViewModel.loadLists()

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
