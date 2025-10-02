import SwiftUI

struct TaskListFormView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""
    @State private var selectedCategory: TaskCategory = .work

    let categories: [TaskCategory]
    let onSave: (String, TaskCategory) -> Void
    private let isEditing: Bool

    init(
        categories: [TaskCategory],
        initialList: TaskList? = nil,
        onSave: @escaping (String, TaskCategory) -> Void
    ) {
        self.categories = categories
        self.onSave = onSave
        self.isEditing = initialList != nil
        _name = State(initialValue: initialList?.name ?? "")
        let defaultCategory = initialList?.category ?? categories.first ?? .work
        _selectedCategory = State(initialValue: defaultCategory)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("form_list_name")) {
                    TextField(LocalizedStringKey("form_list_name_placeholder"), text: $name)
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
            }
            .navigationTitle(Text(isEditing ? "form_edit_list" : "form_add_list"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("action_cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("action_save") {
                        onSave(name, selectedCategory)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TaskListFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListFormView(categories: TaskCategory.allCases) { _, _ in }
    }
}
