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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("form_list")) {
                    Text(listName)
                        .foregroundColor(.primary)
                }

                Section(header: Text("form_category")) {
                    Picker("form_category", selection: $selectedCategory) {
                        ForEach(categories) { category in
                            Text(LocalizedStringKey(category.localizationKey))
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
                        onSave(title, details, dueDate, selectedCategory)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            selectedCategory = categories.first ?? .work
        }
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
