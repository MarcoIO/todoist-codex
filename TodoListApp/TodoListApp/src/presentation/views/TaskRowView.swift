import SwiftUI

struct TaskRowView: View {
    let task: Task

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(task.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)

                Spacer()

                Label {
                    Text(dateFormatter.string(from: task.dueDate))
                } icon: {
                    Image(systemName: "calendar")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            if !task.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(task.details)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                Label {
                    Text(task.listName)
                } icon: {
                    Image(systemName: "folder")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                Label {
                    Text(LocalizedStringKey(task.category.localizationKey))
                } icon: {
                    Image(systemName: task.category.iconName)
                }
                .font(.caption)
                .foregroundColor(.secondary)

                Spacer()

                Text(task.status.localizationKey)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(task.status == .completed ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .foregroundColor(task.status == .completed ? .green : .orange)
                    .clipShape(Capsule())
                    .accessibilityLabel(Text(task.status.localizationKey))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
