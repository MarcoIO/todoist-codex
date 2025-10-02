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
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 16) {
                            Image(systemName: task.iconName)
                                .font(.system(size: 50))
                                .foregroundColor(.accentColor)
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(task.title)
                                    .font(.title)
                                    .bold()
                                Label {
                                    Text(dateFormatter.string(from: task.dueDate))
                                } icon: {
                                    Image(systemName: "calendar")
                                }
                                .foregroundColor(.secondary)
                            }
                        }

                        Text(task.details)
                            .font(.body)

                        Divider()

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

                            Button {
                                viewModel.toggleStatus()
                            } label: {
                                Text(task.status == .completed ? "action_mark_pending" : "action_mark_completed")
                            }
                            .buttonStyle(.borderedProminent)
                        }
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
                    .task {
                        viewModel.loadTask()
                    }
            }
        }
        .navigationTitle(Text("detail_title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadTask()
        }
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let repository = TaskRepositoryImpl(dataSource: CoreDataTaskDataSource(context: PersistenceController(inMemory: true).container.viewContext))
        let useCase = GetTaskByIDUseCase(repository: repository)
        let update = UpdateTaskStatusUseCase(repository: repository)
        let task = Task(iconName: "list.bullet.rectangle", title: "Preview", details: "Details", dueDate: Date(), status: .pending)
        try? repository.add(task: task)
        return NavigationStack {
            TaskDetailView(
                viewModel: TaskDetailViewModel(
                    taskIdentifier: task.id,
                    getTaskByIDUseCase: useCase,
                    updateTaskStatusUseCase: update
                )
            )
        }
    }
}
