import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel = TimerViewModel()
    
    @State private var isShowingSettings = false
    @State private var isShowingAddTask = false
    @State private var isShowingDeleteAlert = false
    @State private var taskToDelete: Task? = nil

    private let focusColor = Color.red.opacity(0.9)
    private let shortBreakColor = Color(red: 135/255, green: 206/255, blue: 235/255)
    private let longBreakColor = Color(red: 152/255, green: 251/255, blue: 152/255)

    private var backgroundColor: Color {
        if viewModel.isDarkModeEnabled { return Color.black }
        switch viewModel.sessionType {
        case .focus: return focusColor
        case .shortBreak: return shortBreakColor
        case .longBreak: return longBreakColor
        }
    }
    
    // --- THIS WAS LIKELY ONE SOURCE OF THE ERRORS ---
    // This computed property needs its full implementation.
    private var buttonAccentColor: Color {
        switch viewModel.sessionType {
        case .focus:
            return .red
        case .shortBreak:
            return .blue
        case .longBreak:
            return .green
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut, value: viewModel.sessionType)
                .animation(.easeInOut, value: viewModel.isDarkModeEnabled)
            
            VStack(spacing: 20) {
                // Top Bar with Settings Button
                HStack {
                    HStack {
                        Button("Pomodoro") { viewModel.selectSession(type: .focus) }
                            .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .focus))
                        
                        Button("Short Rest") { viewModel.selectSession(type: .shortBreak) }
                            .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .shortBreak))
                        
                        Button("Long Rest") { viewModel.selectSession(type: .longBreak) }
                            .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .longBreak))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                Text(viewModel.timeRemaining)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Task List Section
                VStack {
                    ForEach(viewModel.tasks) { task in
                        Button(action: {
                            self.taskToDelete = task
                            self.isShowingDeleteAlert = true
                        }) {
                            HStack {
                                Text(task.name)
                                Spacer()
                                Text("\(task.pomodorosNeeded) Pomodoros")
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    if viewModel.tasks.count < 3 {
                        Button(action: {
                            isShowingAddTask = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Task")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()

                // Control Button
                Button(action: { viewModel.startPause() }) {
                    HStack {
                        Image(systemName: viewModel.timerActive ? "pause.fill" : "play.fill")
                        Text(viewModel.timerActive ? "Pause" : "Start")
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .foregroundColor(buttonAccentColor)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                // Daily Progress
                Text("Today's Pomodoros: \(viewModel.dailySessionsCompleted)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $isShowingAddTask) {
            AddTaskView { (name, pomodoros) in
                viewModel.addTask(name: name, pomodoros: pomodoros)
            }
        }
        .alert("Delete Task", isPresented: $isShowingDeleteAlert, presenting: taskToDelete) { task in
            Button("Confirm Delete", role: .destructive) {
                viewModel.deleteTask(taskToDelete: task)
            }
            Button("Cancel", role: .cancel) {}
        } message: { task in
            Text("Are you sure you want to delete the task \"\(task.name)\"? This cannot be undone.")
        }
    }
}

// --- THIS WAS THE OTHER SOURCE OF THE ERRORS ---
// This custom ButtonStyle needs its full implementation.
struct SessionButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.white.opacity(0.3) : Color.clear
            )
            .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
