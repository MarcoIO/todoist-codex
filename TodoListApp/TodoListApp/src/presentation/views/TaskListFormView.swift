import SwiftUI

struct TaskListFormView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""
    @State private var category: TaskListCategory = .work

    let onSave: (String, TaskListCategory) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("form_list_name")) {
                    TextField(LocalizedStringKey("form_list_name_placeholder"), text: $name)
                }

                Section(header: Text("form_list_category")) {
                    Picker("form_list_category", selection: $category) {
                        ForEach(TaskListCategory.allCases) { category in
                            Label {
                                Text(LocalizedStringKey(category.localizationKey))
                            } icon: {
                                Image(systemName: category.iconName)
                            }
                            .tag(category)
                        }
                    }
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
                        onSave(name, category)
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
        TaskListFormView { _, _ in }
    }
}
