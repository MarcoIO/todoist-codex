import XCTest
@testable import TodoListApp

final class TaskListRepositoryTests: XCTestCase {
    private var persistence: PersistenceController!
    private var repository: TaskListRepositoryImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistence = PersistenceController(inMemory: true)
        let dataSource = CoreDataTaskListDataSource(context: persistence.container.viewContext)
        repository = TaskListRepositoryImpl(dataSource: dataSource)
    }

    override func tearDownWithError() throws {
        persistence = nil
        repository = nil
        try super.tearDownWithError()
    }

    func testAddListPersistsNewList() throws {
        let list = TaskList(name: "Errands", category: .errands)
        try repository.add(list: list)

        let lists = try repository.fetchLists()
        XCTAssertTrue(lists.contains(where: { $0.id == list.id }))
    }

    func testUpdateListPersistsChanges() throws {
        var list = TaskList(name: "Errands", category: .errands)
        try repository.add(list: list)

        list.name = "Updated"
        list.category = .work

        try repository.update(list: list)

        let storedList = try repository.fetchLists().first { $0.id == list.id }
        XCTAssertEqual(storedList?.name, "Updated")
        XCTAssertEqual(storedList?.category, .work)
    }

    func testAddTaskToList() throws {
        let list = TaskList(name: "Personal", category: .personal)
        try repository.add(list: list)
        let task = Task(
            iconName: "star",
            title: "Meditate",
            details: "Take 10 minutes to breathe.",
            dueDate: Date(),
            status: .pending,
            listID: list.id,
            listName: list.name,
            category: .personal
        )

        try repository.add(task: task)

        let lists = try repository.fetchLists()
        let storedList = lists.first(where: { $0.id == list.id })
        XCTAssertEqual(storedList?.tasks.count, 1)
        XCTAssertEqual(storedList?.tasks.first?.title, task.title)
    }

    func testUpdateTaskStatusPersistsChange() throws {
        let list = TaskList(name: "Health", category: .health)
        try repository.add(list: list)
        var task = Task(
            iconName: "heart.fill",
            title: "Run 5km",
            details: "Morning run around the park.",
            dueDate: Date(),
            status: .pending,
            listID: list.id,
            listName: list.name,
            category: .health
        )

        try repository.add(task: task)
        task.status = .completed
        try repository.update(task: task)

        let storedTask = try repository.getTask(by: task.id)
        XCTAssertEqual(storedTask?.status, .completed)
    }
}
