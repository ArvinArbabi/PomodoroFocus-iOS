import Foundation
import Combine
import UserNotifications

// ... SessionType enum remains the same ...
enum SessionType: String {
    case focus = "Pomodoro"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

class TimerViewModel: ObservableObject {
    
    // MARK: - Published Properties for UI
    @Published var sessionType: SessionType = .focus
    @Published var timeRemaining: String = "25:00"
    @Published var timerActive = false
    @Published var dailySessionsCompleted: Int = 0
    @Published var isDarkModeEnabled = false {
        didSet {
            UserDefaults.standard.set(isDarkModeEnabled, forKey: darkModeKey)
        }
    }
    
    // --- NEW PROPERTY FOR TASKS ---
    // This will hold our array of tasks. When it changes, the UI will update
    // and the new array will be saved automatically via the `didSet` block.
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }

    // ... Timer Configuration remains the same ...
    private let focusDuration: Int = 25 * 60
    private let shortBreakDuration: Int = 5 * 60
    private let longBreakDuration: Int = 15 * 60
    private let pomodorosPerCycle: Int = 4
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var totalSeconds: Int = 0
    private var pomodoroCycleCount: Int = 0
    private let userDefaultsKey = "dailySessionsCompleted"
    private let darkModeKey = "isDarkModeEnabled"
    private let tasksKey = "savedTasks" // Key for saving the tasks array.

    init() {
        self.totalSeconds = focusDuration
        
        // Load all saved data on startup
        loadSessionCount()
        isDarkModeEnabled = UserDefaults.standard.bool(forKey: darkModeKey)
        loadTasks() // Load our saved tasks.
        
        updateTimeRemaining()
    }
    
    // MARK: - Task Management Functions
    
    /// Adds a new task to the tasks array.
    func addTask(name: String, pomodoros: Int) {
        let newTask = Task(name: name, pomodorosNeeded: pomodoros)
        tasks.append(newTask)
    }
    
    /// Deletes a specific task from the array.
    func deleteTask(taskToDelete: Task) {
        tasks.removeAll { $0.id == taskToDelete.id }
    }
    
    // MARK: - Data Persistence for Tasks
    
    /// Encodes the tasks array to JSON data and saves it to UserDefaults.
    private func saveTasks() {
        if let encodedData = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedData, forKey: tasksKey)
        }
    }
    
    /// Loads and decodes the tasks array from UserDefaults.
    private func loadTasks() {
        guard let savedData = UserDefaults.standard.data(forKey: tasksKey),
              let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) else {
            return
        }
        self.tasks = decodedTasks
    }
    
    // ... all other functions (startPause, selectSession, etc.) remain exactly the same ...
    
    // MARK: - Public Control Functions
    func startPause() { /* ... no changes ... */ }
    func skipSession() { /* ... no changes ... */ }
    func selectSession(type: SessionType) { /* ... no changes ... */ }
    // MARK: - Timer Logic
    private func start() { /* ... no changes ... */ }
    private func pause() { /* ... no changes ... */ }
    private func nextSession() { /* ... no changes ... */ }
    // MARK: - Helper Functions
    private func updateTimeRemaining() { /* ... no changes ... */ }
    // MARK: - Data Persistence
    private func saveSessionCount() { /* ... no changes ... */ }
    private func loadSessionCount() { /* ... no changes ... */ }
    // MARK: - Notification Logic
    private func scheduleNotification() { /* ... no changes ... */ }
    private func cancelNotification() { /* ... no changes ... */ }

    // NOTE: To save space, the unchanged functions are collapsed.
    // In your project, just add the new Task functions and properties to the existing file.
}
