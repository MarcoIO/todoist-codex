import SwiftUI

struct TaskListFormView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""
    @State private var selectedCategory: TaskCategory = .work

    let categories: [TaskCategory]
    let onSave: (String, TaskCategory) -> Void

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
            .navigationTitle(Text("form_add_list"))
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
        .onAppear {
            selectedCategory = categories.first ?? .work
        }
    }
}

struct TaskListFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListFormView(categories: TaskCategory.allCases) { _, _ in }
    }
}
