import SwiftUI

struct TaskFormView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedCategory: TaskCategory = .work

    let listName: String
    let categories: [TaskCategory]
    let onSave: (String, String, Date, TaskCategory) -> Void
    private let isEditing: Bool

    init(
        listName: String,
        categories: [TaskCategory],
        initialTask: Task? = nil,
        onSave: @escaping (String, String, Date, TaskCategory) -> Void
    ) {
        self.listName = listName
        self.categories = categories
        self.onSave = onSave
        self.isEditing = initialTask != nil
        _title = State(initialValue: initialTask?.title ?? "")
        _details = State(initialValue: initialTask?.details ?? "")
        _dueDate = State(initialValue: initialTask?.dueDate ?? Date())
        let defaultCategory = initialTask?.category ?? categories.first ?? .work
        _selectedCategory = State(initialValue: defaultCategory)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("form_list")) {
                    Label(listName, systemImage: "folder")
                        .foregroundColor(.primary)
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
            .navigationTitle(Text(isEditing ? "form_edit_task" : "form_add_task"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("action_cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("action_save") {
                        onSave(title, details, dueDate, selectedCategory)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TaskFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskFormView(
            listName: NSLocalizedString("sample_list_work", comment: ""),
            categories: TaskCategory.allCases
        ) { _, _, _, _ in }
    }
}
