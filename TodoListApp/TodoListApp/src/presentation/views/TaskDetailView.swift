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
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 18) {
                            labeledContent(title: "Titulo") {
                                Text(task.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }

                            labeledContent(title: "Fecha") {
                                Text(dateFormatter.string(from: task.dueDate))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            labeledContent(title: "Descripcion") {
                                Text(task.details)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.vertical, 28)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            infoRow(title: "form_list", value: Text(task.listName))
                            infoRow(title: "form_category", value: Text(LocalizedStringKey(task.category.localizationKey)))
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            Text(task.status.localizationKey)
                                .font(.headline)
                                .foregroundColor(task.status == .completed ? .green : .orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background((task.status == .completed ? Color.green : Color.orange).opacity(0.15))
                                .clipShape(Capsule())

                            Button(action: {
                                viewModel.toggleStatus()
                            }) {
                                Text(task.status == .completed ? "action_mark_pending" : "action_mark_completed")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
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

    private func infoRow(title: LocalizedStringKey, value: Text) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            value
                .font(.headline)
                .foregroundColor(.primary)
        }
    }

    private func labeledContent<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(nil)
            content()
        }
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let repository = TaskListRepositoryImpl(dataSource: CoreDataTaskListDataSource(context: PersistenceController(inMemory: true).container.viewContext))
        let useCase = GetTaskByIDUseCase(repository: repository)
        let update = UpdateTaskStatusUseCase(repository: repository)
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
                    updateTaskStatusUseCase: update
                )
            )
        }
        .background(Color(.systemGroupedBackground))
    }
}
