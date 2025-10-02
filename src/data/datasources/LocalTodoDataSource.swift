import Foundation

/// Contract defining operations for a local TODO data source.
protocol LocalTodoDataSource {
    /// Loads all persisted TODO entities.
    /// - Returns: The collection of persisted entities.
    func loadTodos() throws -> [TodoEntity]

    /// Persists the provided TODO entities collection.
    /// - Parameter todos: The entities to persist.
    func saveTodos(_ todos: [TodoEntity]) throws
}

/// JSON-backed implementation of ``LocalTodoDataSource`` using the documents directory.
final class JsonFileTodoDataSource: LocalTodoDataSource {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "JsonFileTodoDataSourceQueue", qos: .userInitiated)

    /// Creates a JSON-backed data source storing information under the provided file name.
    /// - Parameter fileName: Name of the JSON file to store data.
    init(fileName: String = "todos.json") {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        fileURL = directory.appendingPathComponent(fileName)
    }

    func loadTodos() throws -> [TodoEntity] {
        try queue.sync {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return []
            }
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([TodoEntity].self, from: data)
        }
    }

    func saveTodos(_ todos: [TodoEntity]) throws {
        try queue.sync {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(todos)
            try data.write(to: fileURL, options: [.atomic])
        }
    }
}
