import SwiftUI

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()

    init(viewModel: TaskDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if let task = viewModel.task {
                let detailsText = trimmedDetails(for: task)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(task.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)

                            Label {
                                Text(dateFormatter.string(from: task.dueDate))
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .foregroundColor(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Label {
                                Text(task.listName)
                            } icon: {
                                Image(systemName: "folder")
                            }
                            .font(.headline)

                            Label {
                                Text(LocalizedStringKey(task.category.localizationKey))
                            } icon: {
                                Image(systemName: task.category.iconName)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("form_description")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text(detailsText.isEmpty ? NSLocalizedString("form_description_placeholder", comment: "") : detailsText)
                                .font(.body)
                                .foregroundColor(detailsText.isEmpty ? .secondary : .primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            Text("detail_status_section")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            HStack {
                                Label(
                                    title: { Text(task.status.localizationKey) },
                                    icon: {
                                        Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "clock")
                                    }
                                )
                                .font(.headline)
                                .foregroundColor(task.status == .completed ? .green : .orange)

                                Spacer()

                                Button(action: {
                                    viewModel.toggleStatus()
                                }) {
                                    Text(task.status == .completed ? "action_mark_pending" : "action_mark_completed")
                                        .font(.headline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.accentColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .padding()
                }
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("error_title")
                        .font(.headline)
                    Text(error)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                ProgressView()
            }
        }
        .navigationTitle(Text("detail_title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadTask()
        }
    }

    private func trimmedDetails(for task: Task) -> String {
        task.details.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let repository = TaskListRepositoryImpl(dataSource: CoreDataTaskListDataSource(context: PersistenceController(inMemory: true).container.viewContext))
        let useCase = GetTaskByIDUseCase(repository: repository)
        let update = UpdateTaskUseCase(repository: repository)
        let list = TaskList(name: NSLocalizedString("sample_list_work", comment: ""), category: .work)
        let task = Task(
            iconName: "list.bullet.rectangle",
            title: NSLocalizedString("sample_task_title_plan", comment: ""),
            details: NSLocalizedString("sample_task_details_plan", comment: ""),
            dueDate: Date(),
            status: .pending,
            listID: list.id,
            listName: list.name,
            category: .work
        )
        try? repository.add(list: list)
        try? repository.add(task: task)
        return NavigationView {
            TaskDetailView(
                viewModel: TaskDetailViewModel(
                    taskIdentifier: task.id,
                    getTaskByIDUseCase: useCase,
                    updateTaskUseCase: update
                )
            )
        }
    }
}
