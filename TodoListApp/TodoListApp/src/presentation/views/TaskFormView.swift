import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var iconName: String = "list.bullet.circle"
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()

    let onSave: (String, String, String, Date) -> Void

    private let availableIcons: [String] = [
        "list.bullet.circle",
        "list.bullet.clipboard",
        "tray.full",
        "calendar",
        "star",
        "bell"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("form_icon")) {
                    Picker(selection: $iconName) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Label(
                                title: { Text(iconTitle(for: icon)) },
                                icon: { Image(systemName: icon) }
                            )
                            .tag(icon)
                        }
                    } label: {
                        Text("form_icon")
                    }
                }

                Section(header: Text("form_title")) {
                    TextField(LocalizedStringKey("form_title_placeholder"), text: $title)
                }

                Section(header: Text("form_description")) {
                    TextField(LocalizedStringKey("form_description_placeholder"), text: $details, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section(header: Text("form_due_date")) {
                    DatePicker(
                        selection: $dueDate,
                        displayedComponents: [.date]
                    ) {
                        Text("form_due_date")
                    }
                }
            }
            .navigationTitle(Text("form_add_task"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("action_cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("action_save") {
                        onSave(iconName, title, details, dueDate)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func iconTitle(for icon: String) -> String {
        switch icon {
        case "list.bullet.circle":
            return NSLocalizedString("icon_tasks", comment: "")
        case "list.bullet.clipboard":
            return NSLocalizedString("icon_clipboard", comment: "")
        case "tray.full":
            return NSLocalizedString("icon_inbox", comment: "")
        case "calendar":
            return NSLocalizedString("icon_calendar", comment: "")
        case "star":
            return NSLocalizedString("icon_star", comment: "")
        case "bell":
            return NSLocalizedString("icon_bell", comment: "")
        default:
            return icon
        }
    }
}

struct TaskFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskFormView { _, _, _, _ in }
    }
}
