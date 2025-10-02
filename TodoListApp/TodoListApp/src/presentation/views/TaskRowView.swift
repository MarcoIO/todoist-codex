import SwiftUI

struct TaskRowView: View {
    let task: Task

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private var statusColor: Color {
        task.status == .completed ? .green : .orange
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(task.status.localizationKey)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("task_row_description_label")

                Text(task.details)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Text(task.listName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    fieldLabel("task_row_date_label")
                        .multilineTextAlignment(.trailing)

                    Text(dateFormatter.string(from: task.dueDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("task_row_category_label")

                Text(LocalizedStringKey(task.category.localizationKey))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())
                    .accessibilityLabel(Text(LocalizedStringKey(task.category.localizationKey)))
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private func fieldLabel(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.secondary)
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
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
