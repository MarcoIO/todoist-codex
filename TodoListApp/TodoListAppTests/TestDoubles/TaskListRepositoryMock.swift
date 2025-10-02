import Foundation
@testable import TodoListApp

final class TaskListRepositoryMock: TaskListRepository {
    var lists: [TaskList] = []
    var fetchListsError: Error?
    var addListError: Error?
    var updateListError: Error?
    var deleteListError: Error?
    var addTaskError: Error?
    var updateTaskError: Error?
    var deleteTaskError: Error?
    var getTaskResult: Result<Task?, Error> = .success(nil)

    func fetchLists() throws -> [TaskList] {
        if let error = fetchListsError {
            throw error
        }
        return lists
    }

    func add(list: TaskList) throws {
        if let error = addListError {
            throw error
        }
        lists.append(list)
    }

    func update(list: TaskList) throws {
        if let error = updateListError {
            throw error
        }
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else {
            throw TaskDataSourceError.listNotFound
        }
        lists[index] = list
    }

    func deleteList(identifier: UUID) throws {
        if let error = deleteListError {
            throw error
        }
        lists.removeAll { $0.id == identifier }
    }

    func add(task: Task) throws {
        if let error = addTaskError {
            throw error
        }
        guard let index = lists.firstIndex(where: { $0.id == task.listID }) else {
            throw TaskDataSourceError.listNotFound
        }
        var list = lists[index]
        list.tasks.append(task)
        lists[index] = list
    }

    func update(task: Task) throws {
        if let error = updateTaskError {
            throw error
        }
        guard let listIndex = lists.firstIndex(where: { $0.id == task.listID }) else {
            throw TaskDataSourceError.listNotFound
        }
        var list = lists[listIndex]
        guard let taskIndex = list.tasks.firstIndex(where: { $0.id == task.id }) else {
            throw TaskDataSourceError.taskNotFound
        }
        list.tasks[taskIndex] = task
        lists[listIndex] = list
    }

    func deleteTask(identifier: UUID) throws {
        if let error = deleteTaskError {
            throw error
        }
        lists = lists.map { list in
            var mutableList = list
            mutableList.tasks.removeAll { $0.id == identifier }
            return mutableList
        }
    }

    func getTask(by identifier: UUID) throws -> Task? {
        switch getTaskResult {
        case .success(let task):
            if let task {
                return task
            }
            return lists.flatMap { $0.tasks }.first { $0.id == identifier }
        case .failure(let error):
            throw error
        }
    }
}
