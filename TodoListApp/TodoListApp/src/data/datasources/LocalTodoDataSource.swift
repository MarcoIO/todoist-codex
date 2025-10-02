import Foundation

/// Defines a simple file based persistence that works as a local database without third party dependencies.
final class LocalTodoDataSource {
    enum DataSourceError: Error, LocalizedError {
        case notFound
        case failedToSave

        var errorDescription: String? {
            switch self {
            case .notFound:
                return "Item not found"
            case .failedToSave:
                return "Unable to persist data"
            }
        }
    }

    private let fileURL: URL
    private let queue = DispatchQueue(label: "LocalTodoDataSourceQueue", qos: .userInitiated)

    init(
        fileManager: FileManager = .default,
        directory: URL? = nil,
        filename: String = "todos.json",
        seedIfNeeded: Bool = true
    ) {
        if let directory {
            self.fileURL = directory.appendingPathComponent(filename)
        } else {
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let baseURL = urls.first ?? fileManager.temporaryDirectory
            self.fileURL = baseURL.appendingPathComponent(filename)
        }
        if seedIfNeeded {
            ensureInitialSeed()
        }
    }

    func fetchAll() throws -> [TodoEntity] {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([TodoEntity].self, from: data)
    }

    func get(by identifier: UUID) throws -> TodoEntity {
        let items = try fetchAll()
        guard let entity = items.first(where: { $0.id == identifier }) else {
            throw DataSourceError.notFound
        }
        return entity
    }

    func save(_ entity: TodoEntity) throws {
        var items = try fetchAll()
        if let index = items.firstIndex(where: { $0.id == entity.id }) {
            items[index] = entity
        } else {
            items.append(entity)
        }
        try persist(items)
    }

    func delete(_ identifier: UUID) throws {
        var items = try fetchAll()
        let newItems = items.filter { $0.id != identifier }
        guard newItems.count != items.count else {
            throw DataSourceError.notFound
        }
        try persist(newItems)
    }

    private func persist(_ entities: [TodoEntity]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(entities)
        do {
            try queue.sync {
                let directoryURL = fileURL.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: directoryURL.path) {
                    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                }
                try data.write(to: fileURL, options: [.atomic])
            }
        } catch {
            throw DataSourceError.failedToSave
        }
    }

    private func ensureInitialSeed() {
        guard !FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        let sampleItems: [TodoEntity] = [
            TodoEntity(
                id: UUID(),
                iconName: "book.fill",
                title: "Learn SwiftUI",
                details: "Review the new data flow APIs and design patterns.",
                dueDate: Date().addingTimeInterval(60 * 60 * 24 * 2),
                status: .inProgress
            ),
            TodoEntity(
                id: UUID(),
                iconName: "cart.fill",
                title: "Grocery shopping",
                details: "Buy vegetables, fruits and ingredients for dinner.",
                dueDate: Date().addingTimeInterval(60 * 60 * 24 * 3),
                status: .pending
            )
        ]
        try? persist(sampleItems)
    }
}
