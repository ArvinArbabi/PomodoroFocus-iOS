import SwiftUI

struct AddTaskView: View {
    // MARK: - Properties
    
    // @State properties are used for view-specific, local state.
    // Here, they hold the temporary values for the new task being created.
    @State private var taskName: String = ""
    @State private var pomodoroCount: Int = 1

    // This is a "callback" function. The view that shows this sheet
    // will provide the code for what to do when the user taps "Done".
    var onAddTask: (String, Int) -> Void
    
    // The dismiss function lets us programmatically close this sheet.
    @Environment(\.dismiss) var dismiss

    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    // A TextField for entering the task's name.
                    TextField("e.g., Finish SwiftUI project", text: $taskName)
                    
                    // A Stepper is a simple +/- control for numbers.
                    // We limit the range to be between 1 and 10 Pomodoros.
                    Stepper("Pomodoros needed: \(pomodoroCount)", value: $pomodoroCount, in: 1...10)
                }
            }
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // This places the "Cancel" button on the top-left.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss() // Closes the sheet without doing anything.
                    }
                }
                
                // This places the "Done" button on the top-right.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // When tapped, call the callback function with the new task's data.
                        onAddTask(taskName, pomodoroCount)
                        dismiss() // Close the sheet.
                    }
                    // The button is disabled if the user hasn't typed a name.
                    .disabled(taskName.isEmpty)
                }
            }
        }
    }
}
