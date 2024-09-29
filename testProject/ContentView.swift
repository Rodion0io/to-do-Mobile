import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var newTaskText = ""
    @State private var showingShareSheet = false
    @State private var showingDocumentPicker = false
    @State private var fileURL: URL?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.tasks) { task in
                        TaskRow(task: task, viewModel: viewModel)
                    }
                    .onDelete(perform: viewModel.deleteTask)
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    viewModel.fetchTasks()
                }
                
                HStack {
                    TextField("Новое дело", text: $newTaskText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        viewModel.addTask(description: newTaskText)
                        newTaskText = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 10)
                }
                
                HStack {
                    Button(action: {
                        if let url = viewModel.saveTasksToJSON() {
                            fileURL = url
                            showingShareSheet = true
                        }
                    }) {
                        Text("Сохранить")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 10)
                    
                    Button(action: {
                        showingDocumentPicker = true
                    }) {
                        Text("Загрузить")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 10)
                    
                    Button(action: {
                        viewModel.clearAllTasks()
                    }) {
                        Text("Очистить")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 10)
                    
                }
                .navigationTitle("TO-DO List")
                .onAppear {
                    viewModel.fetchTasks()
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let url = fileURL {
                        ShareSheet(activityItems: [url])
                    }
                }
                .sheet(isPresented: $showingDocumentPicker) {
                    DocumentPicker(viewModel: viewModel)
                }
            }
        }
    }
}
