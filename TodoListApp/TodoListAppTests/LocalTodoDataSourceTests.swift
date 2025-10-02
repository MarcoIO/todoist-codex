import XCTest
@testable import TodoListApp

final class LocalTodoDataSourceTests: XCTestCase {
    private var temporaryDirectory: URL!

    override func setUpWithError() throws {
        temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    override func tearDownWithError() throws {
        if let directory = temporaryDirectory {
            try? FileManager.default.removeItem(at: directory)
        }
        temporaryDirectory = nil
    }

    func testPersistsAndFetchesItems() throws {
        let dataSource = LocalTodoDataSource(directory: temporaryDirectory, seedIfNeeded: false)
        let entity = TodoEntity(
            id: UUID(),
            iconName: "star.fill",
            title: "Test",
            details: "Details",
            dueDate: Date(),
            status: .pending
        )

        try dataSource.save(entity)
        let stored = try dataSource.fetchAll()
        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(stored.first?.title, "Test")
    }

    func testDeleteRemovesItem() throws {
        let dataSource = LocalTodoDataSource(directory: temporaryDirectory, seedIfNeeded: false)
        let identifier = UUID()
        let entity = TodoEntity(
            id: identifier,
            iconName: "star.fill",
            title: "Delete",
            details: "Remove",
            dueDate: Date(),
            status: .pending
        )
        try dataSource.save(entity)
        try dataSource.delete(identifier)
        XCTAssertTrue(try dataSource.fetchAll().isEmpty)
    }
}
