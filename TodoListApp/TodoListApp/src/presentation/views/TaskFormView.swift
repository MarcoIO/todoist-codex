import SwiftUI

struct TaskFormView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var iconName: String = "list.bullet.circle"
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedCategory: TaskCategory = .work

    let listName: String
    let categories: [TaskCategory]
    let onSave: (String, String, String, Date, TaskCategory) -> Void

    private let availableIcons: [String] = [
        "list.bullet.circle",
        "list.bullet.clipboard",
        "tray.full",
        "calendar",
        "star",
        "bell"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("form_list")) {
                    Label(listName, systemImage: "folder")
                        .foregroundColor(.primary)
                }

                Section(header: Text("form_icon")) {
                    Picker("form_icon", selection: $iconName) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Label(
                                title: { Text(iconTitle(for: icon)) },
                                icon: { Image(systemName: icon) }
                            )
                            .tag(icon)
                        }
                    }
                }

                Section(header: Text("form_category")) {
                    Picker("form_category", selection: $selectedCategory) {
                        ForEach(categories) { category in
                            Label(
                                title: { Text(LocalizedStringKey(category.localizationKey)) },
                                icon: { Image(systemName: category.iconName) }
                            )
                            .tag(category)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section(header: Text("form_title")) {
                    TextField(LocalizedStringKey("form_title_placeholder"), text: $title)
                }

                Section(header: Text("form_description")) {
                    ZStack(alignment: .topLeading) {
                        if details.isEmpty {
                            Text("form_description_placeholder")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $details)
                            .frame(minHeight: 120)
                    }
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
                    Button("action_cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("action_save") {
                        onSave(iconName, title, details, dueDate, selectedCategory)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            selectedCategory = categories.first ?? .work
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
        TaskFormView(
            listName: NSLocalizedString("sample_list_work", comment: ""),
            categories: TaskCategory.allCases
        ) { _, _, _, _, _ in }
    }
}
