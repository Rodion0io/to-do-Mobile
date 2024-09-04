import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []

    func addTask(description: String) {
        let newTask = Task(description: description, isCompleted: false)
        tasks.append(newTask)
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func updateTaskDescription(task: Task, newDescription: String) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].description = newDescription
        }
    }

    func saveTasksToJSON() -> URL? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tasks) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let saveFileURL = documentsDirectory.appendingPathComponent("tasks.json")
            do {
                try encoded.write(to: saveFileURL)
                return saveFileURL
            } catch {
                print("Failed to save tasks: \(error)")
            }
        }
        return nil
    }

    func loadTasksFromJSON(from url: URL) {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: url)
            let decodedTasks = try decoder.decode([Task].self, from: data)
            self.tasks = decodedTasks
        } catch {
            print("Failed to load tasks: \(error)")
        }
    }
}
