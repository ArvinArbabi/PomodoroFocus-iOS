import Foundation
import Combine
import UserNotifications

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
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }

    // MARK: - Timer Configuration
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
    private let tasksKey = "savedTasks"
    private let lastSessionDateKey = "lastSessionDate" // NEW: Key to store the last session date.

    init() {
        self.totalSeconds = focusDuration
        
        // This new function now checks the date before loading the count.
        checkAndResetDailyCount()
        
        isDarkModeEnabled = UserDefaults.standard.bool(forKey: darkModeKey)
        loadTasks()
        updateTimeRemaining()
    }
    
    // MARK: - Public Control Functions
    // ... all public functions remain the same ...
    func startPause() { /* ... unchanged ... */ }
    func skipSession() { /* ... unchanged ... */ }
    func selectSession(type: SessionType) { /* ... unchanged ... */ }
    
    // MARK: - Task Management Functions
    // ... all task functions remain the same ...
    func addTask(name: String, pomodoros: Int) { /* ... unchanged ... */ }
    func deleteTask(taskToDelete: Task) { /* ... unchanged ... */ }
    
    // MARK: - Data Persistence
    
    // NEW: This function now contains the daily reset logic.
    private func checkAndResetDailyCount() {
        let lastDate = UserDefaults.standard.object(forKey: lastSessionDateKey) as? Date
        
        // If a last date was saved, check if it's from a previous day.
        if let lastDate = lastDate, !Calendar.current.isDateInToday(lastDate) {
            // It's a new day, so reset the counter to 0.
            dailySessionsCompleted = 0
            saveSessionCount()
        } else {
            // It's the same day, so just load the existing count.
            loadSessionCount()
        }
    }
    
    // UPDATED: This function now also saves the current date.
    private func saveSessionCount() {
        DispatchQueue.global(qos: .background).async {
            UserDefaults.standard.set(self.dailySessionsCompleted, forKey: self.userDefaultsKey)
            // Also save the current date every time we save the count.
            UserDefaults.standard.set(Date(), forKey: self.lastSessionDateKey)
        }
    }
    
    private func loadSessionCount() {
        dailySessionsCompleted = UserDefaults.standard.integer(forKey: userDefaultsKey)
    }
    
    // ... rest of the file is unchanged ...
    
    private func saveTasks() { /* ... unchanged ... */ }
    private func loadTasks() { /* ... unchanged ... */ }
    private func start() { /* ... unchanged ... */ }
    private func pause() { /* ... unchanged ... */ }
    private func nextSession() { /* ... unchanged ... */ }
    private func updateTimeRemaining() { /* ... unchanged ... */ }
    private func scheduleNotification() { /* ... unchanged ... */ }
    private func cancelNotification() { /* ... unchanged ... */ }
}
