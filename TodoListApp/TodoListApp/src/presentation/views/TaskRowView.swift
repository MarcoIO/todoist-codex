import SwiftUI

struct TaskRowView: View {
    let task: Task

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: task.iconName)
                .font(.system(size: 28))
                .foregroundColor(task.status == .completed ? .green : .accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)

                Text(task.listName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Label {
                        Text(LocalizedStringKey(task.category.localizationKey))
                    } icon: {
                        Image(systemName: task.category.iconName)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    Text(dateFormatter.string(from: task.dueDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "clock")
                .foregroundColor(task.status == .completed ? .green : .orange)
                .accessibilityLabel(Text(task.status.localizationKey))
        }
        .padding(.vertical, 8)
    }
}

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        TaskRowView(
            task: Task(
                iconName: "list.bullet.rectangle",
                title: NSLocalizedString("sample_task_title_plan", comment: ""),
                details: NSLocalizedString("sample_task_details_plan", comment: ""),
                dueDate: Date(),
                status: .pending,
                listID: UUID(),
                listName: NSLocalizedString("sample_list_work", comment: ""),
                category: .work
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
