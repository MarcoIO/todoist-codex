import SwiftUI

/// Screen that shows detailed information for a TODO item.
struct TodoDetailScene: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var viewModel: TodoDetailViewModel

    init(viewModel: TodoDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if let item = viewModel.item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: item.iconName)
                                .font(.system(size: 48))
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.title)
                                    .bold()
                                Text(formatted(date: item.dueDate))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Text(item.details)
                            .font(.body)
                            .padding(.top, 8)
                        HStack {
                            Text(languageManager.localized(item.status.localizedKey()))
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(statusColor(for: item.status))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            Spacer()
                            Button(action: viewModel.toggleCompletion) {
                                Label(languageManager.localized("detail.toggle"), systemImage: "checkmark.circle")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        Spacer()
                    }
                    .padding()
                }
            } else if let message = viewModel.errorMessage {
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ProgressView()
            }
        }
        .navigationTitle(languageManager.localized("detail.title"))
        .onAppear(perform: viewModel.load)
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: languageManager.current.rawValue)
        return formatter.string(from: date)
    }

    private func statusColor(for status: TodoStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .inProgress:
            return .blue
        case .completed:
            return .green
        }
    }
}
