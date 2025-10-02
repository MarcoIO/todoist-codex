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
                Text(dateFormatter.string(from: task.dueDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Label {
                    Text(LocalizedStringKey(task.category.localizationKey))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: task.category.iconName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
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
                listID: UUID(),
                iconName: "list.bullet.rectangle",
                title: "Plan roadmap",
                details: "Review milestones for next sprint.",
                dueDate: Date(),
                status: .pending,
                category: .planning
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
