import SwiftUI

struct TaskRow: View {
    var task: Task
    @ObservedObject var viewModel: TaskViewModel
    @State private var isEditing = false
    @State private var editedText = ""

    var body: some View {
        HStack {
            if isEditing {
                TextField("Редактировать дело", text: $editedText, onCommit: {
                    viewModel.updateTaskDescription(task: task, newDescription: editedText)
                    isEditing = false
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Button(action: {
                    viewModel.toggleTaskCompletion(task: task)
                }) {
                    Image(systemName: task.isSelected ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(task.isSelected ? .green : .gray)
                }
                .buttonStyle(BorderlessButtonStyle())

                Text(task.text)
                    .strikethrough(task.isSelected)
                    .foregroundColor(task.isSelected ? .gray : .primary)
                    .onTapGesture {
                        isEditing = true
                        editedText = task.text
                    }
            }
        }
    }
}
