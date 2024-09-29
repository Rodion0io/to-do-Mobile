import Foundation
import UIKit

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private let baseURL = "http://localhost:5258/api/Values/"

    // Загрузка задач с сервера
    func fetchTasks() {
        guard let url = URL(string: "\(baseURL)getList") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка получения данных: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let decodedTasks = try JSONDecoder().decode([Task].self, from: data)
                    DispatchQueue.main.async {
                        self.tasks = decodedTasks
                    }
                } catch {
                    print("Ошибка декодирования задач: \(error)")
                }
            }
        }.resume()
    }

    // Добавление новой задачи
    func addTask(description: String) {
        guard let url = URL(string: "\(baseURL)addEvent") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = Task(id: UUID(), text: description, isSelected: false)
        
        do {
            request.httpBody = try JSONEncoder().encode(task)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Ошибка при добавлении задачи: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.tasks.append(task)
                }
            }.resume()
        } catch {
            print("Ошибка кодирования задачи: \(error)")
        }
    }

    // Удаление задачи
    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = tasks[index]
            guard let url = URL(string: "\(baseURL)delete/\(task.id)") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Ошибка при удалении задачи: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.tasks.remove(at: index)
                }
            }.resume()
        }
    }
    
    // Очистка всего списка задач на сервере
    func clearAllTasks() {
        guard let url = URL(string: "\(baseURL)clear") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка при очистке задач: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.tasks.removeAll()
            }
        }.resume()
    }

    // Обновление описания задачи
    func updateTaskDescription(task: Task, newDescription: String) {
        guard let url = URL(string: "\(baseURL)changeText/\(task.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var updatedTask = task
        updatedTask.text = newDescription
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedTask)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Ошибка при обновлении задачи: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                        self.tasks[index].text = newDescription
                    }
                }
            }.resume()
        } catch {
            print("Ошибка кодирования задачи: \(error)")
        }
    }

    // Переключение статуса задачи
    func toggleTaskCompletion(task: Task) {
        guard let url = URL(string: "\(baseURL)changeIndicator/\(task.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var updatedTask = task
        updatedTask.isSelected.toggle()
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedTask)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Ошибка при переключении состояния задачи: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                        self.tasks[index].isSelected.toggle()
                    }
                }
            }.resume()
        } catch {
            print("Ошибка кодирования задачи: \(error)")
        }
    }

    // Метод для сохранения задач в JSON
    func saveTasksToJSON() -> URL? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(tasks)
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = "tasks.json"
            let tempURL = tempDirectory.appendingPathComponent(fileName)
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Ошибка при сохранении задач в JSON: \(error)")
            return nil
        }
    }
    
    // Метод для экспорта JSON в файловую систему
    func exportTasksToFiles() {
        guard let tempURL = saveTasksToJSON() else {
            print("Не удалось сохранить задачи в файл.")
            return
        }
        
        let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }

    // Отправка задач на сервер
    func uploadTasksToServer(from fileURL: URL) {
        do {
            let data = try Data(contentsOf: fileURL)
            guard let url = URL(string: "\(baseURL)newList") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Ошибка при отправке задач: \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("Ответ сервера: \(responseString)")
                        }
                    } catch {
                        print("Ошибка декодирования ответа сервера: \(error)")
                    }
                }
            }.resume()
        } catch {
            print("Ошибка чтения файла: \(error)")
        }
    }
}
