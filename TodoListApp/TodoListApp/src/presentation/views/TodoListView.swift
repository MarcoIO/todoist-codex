import SwiftUI

/// SwiftUI view that presents the list of TODO items.
struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @EnvironmentObject private var languageManager: LanguageManager

    init(viewModel: TodoListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let message = viewModel.errorMessage {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.items.isEmpty {
                    LocalizedText("list.empty")
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            NavigationLink(value: item.id) {
                                TodoRowView(item: item)
                                    .environmentObject(languageManager)
                            }
                        }
                        .onDelete(perform: viewModel.delete)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationDestination(for: UUID.self) { identifier in
                TodoDetailScene(viewModel: dependencyContainer.detailViewModel(identifier: identifier))
                    .environmentObject(languageManager)
            }
            .navigationTitle(languageManager.localized("list.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker(selection: $languageManager.current) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayName).tag(language)
                            }
                        } label: {
                            EmptyView()
                        }
                    } label: {
                        Image(systemName: "globe")
                    }
                }
            }
            .onAppear(perform: viewModel.load)
        }
        .environmentObject(languageManager)
    }
}

private struct TodoRowView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    let item: TodoListItemViewData

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: languageManager.current.rawValue)
        return formatter
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: item.iconName)
                .font(.system(size: 28))
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(dateFormatter.string(from: item.dueDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(languageManager.localized(item.status.localizedKey()))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
    }

    private var statusColor: Color {
        switch item.status {
        case .pending:
            return .orange
        case .inProgress:
            return .blue
        case .completed:
            return .green
        }
    }
}
