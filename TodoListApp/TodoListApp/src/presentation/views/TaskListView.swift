import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var languageController: LanguageController
    @StateObject private var viewModel: TaskListViewModel

    @State private var isPresentingListForm = false
    @State private var listForTaskForm: TaskList?

    private let detailBuilder: (Task) -> TaskDetailView

    init(
        viewModel: TaskListViewModel,
        detailBuilder: @escaping (Task) -> TaskDetailView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.detailBuilder = detailBuilder
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.lists.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.stack.3d.up")
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
                        ForEach(Array(viewModel.lists.enumerated()), id: \.element.id) { index, list in
                            Section(header: listHeader(for: list, index: index)) {
                                if list.tasks.isEmpty {
                                    Text("empty_list_tasks")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                } else {
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
                                                        viewModel.delete(task: task)
                                                    }) {
                                                        Label("action_delete", systemImage: "trash")
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                        }
                                    }
                                    .onDelete { offsets in
                                        viewModel.deleteTasks(in: list, at: offsets)
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
                    Menu {
                        Button {
                            isPresentingListForm = true
                        } label: {
                            Label("action_add_list", systemImage: "square.and.pencil")
                        }

                        if !viewModel.lists.isEmpty {
                            Divider()
                            ForEach(viewModel.lists) { list in
                                Button {
                                    listForTaskForm = list
                                } label: {
                                    Label(list.name, systemImage: "plus")
                                }
                            }
                        }
                    } label: {
                        Label("action_add", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $listForTaskForm) { list in
                TaskFormView { icon, title, details, date, category in
                    viewModel.addTask(
                        in: list,
                        iconName: icon,
                        title: title,
                        details: details,
                        dueDate: date,
                        category: category
                    )
                }
                .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
            }
            .sheet(isPresented: $isPresentingListForm) {
                TaskListFormView { name, category in
                    viewModel.addList(name: name, category: category)
                }
                .environment(\.locale, Locale(identifier: languageController.currentLanguage.localeIdentifier))
            }
            .onAppear {
                viewModel.loadData()
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

    private func listHeader(for list: TaskList, index: Int) -> some View {
        HStack {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(list.name)
                        .font(.headline)
                    Text(LocalizedStringKey(list.category.localizationKey))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } icon: {
                Image(systemName: list.category.iconName)
            }

            Spacer()

            Button {
                listForTaskForm = list
            } label: {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
            }
            .buttonStyle(BorderlessButtonStyle())
            .accessibilityLabel(Text("action_add_task"))
            .contextMenu {
                Button(action: {
                    viewModel.deleteLists(at: IndexSet(integer: index))
                }) {
                    Label("action_delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        let persistence = PersistenceController(inMemory: true)
        let repository = TaskListRepositoryImpl(dataSource: CoreDataTaskDataSource(context: persistence.container.viewContext))
        let fetch = FetchTaskListsUseCase(repository: repository)
        let addList = AddTaskListUseCase(repository: repository)
        let deleteList = DeleteTaskListUseCase(repository: repository)
        let addTask = AddTaskUseCase(repository: repository)
        let updateTask = UpdateTaskStatusUseCase(repository: repository)
        let deleteTask = DeleteTaskUseCase(repository: repository)
        let viewModel = TaskListViewModel(
            fetchTaskListsUseCase: fetch,
            addTaskListUseCase: addList,
            deleteTaskListUseCase: deleteList,
            addTaskUseCase: addTask,
            updateTaskUseCase: updateTask,
            deleteTaskUseCase: deleteTask
        )
        viewModel.loadData()

        return TaskListView(viewModel: viewModel) { task in
            TaskDetailView(
                viewModel: TaskDetailViewModel(
                    taskIdentifier: task.id,
                    getTaskByIDUseCase: GetTaskByIDUseCase(repository: repository),
                    updateTaskStatusUseCase: updateTask
                )
            )
        }
        .environmentObject(LanguageController())
    }
}
