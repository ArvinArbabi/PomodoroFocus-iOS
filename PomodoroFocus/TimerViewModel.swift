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

    init() {
        self.totalSeconds = focusDuration
        loadSessionCount()
        isDarkModeEnabled = UserDefaults.standard.bool(forKey: darkModeKey)
        loadTasks()
        updateTimeRemaining()
    }
    
    // MARK: - Public Control Functions
    
    func startPause() {
        if timerActive {
            pause()
        } else {
            start()
        }
    }
    
    func skipSession() {
        pause()
        nextSession()
    }

    // --- THIS IS THE KEY FUNCTION THAT WAS LIKELY BROKEN ---
    // It handles the logic for the top three session buttons.
    func selectSession(type: SessionType) {
        pause() // Stop any running timer.
        sessionType = type // Set the new session type.

        // Update the total seconds based on the selected type.
        switch type {
        case .focus:
            totalSeconds = focusDuration
        case .shortBreak:
            totalSeconds = shortBreakDuration
        case .longBreak:
            totalSeconds = longBreakDuration
        }
        
        updateTimeRemaining() // Update the time display string.
    }
    
    // MARK: - Task Management Functions
    
    func addTask(name: String, pomodoros: Int) {
        let newTask = Task(name: name, pomodorosNeeded: pomodoros)
        tasks.append(newTask)
    }
    
    func deleteTask(taskToDelete: Task) {
        tasks.removeAll { $0.id == taskToDelete.id }
    }
    
    // MARK: - Data Persistence for Tasks
    
    private func saveTasks() {
        if let encodedData = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedData, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        guard let savedData = UserDefaults.standard.data(forKey: tasksKey),
              let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) else {
            return
        }
        self.tasks = decodedTasks
    }
    
    // MARK: - Timer Logic
    private func start() {
        timerActive = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            
            if self.totalSeconds > 0 {
                self.totalSeconds -= 1
                self.updateTimeRemaining()
            } else {
                self.pause()
                self.nextSession()
            }
        }
        scheduleNotification()
    }
    
    private func pause() {
        timerActive = false
        timer?.cancel()
        cancelNotification()
    }
    
    private func nextSession() {
        if sessionType == .focus {
            dailySessionsCompleted += 1
            pomodoroCycleCount += 1
            saveSessionCount()
            
            if pomodoroCycleCount >= pomodorosPerCycle {
                sessionType = .longBreak
                totalSeconds = longBreakDuration
                pomodoroCycleCount = 0
            } else {
                sessionType = .shortBreak
                totalSeconds = shortBreakDuration
            }
        } else {
            sessionType = .focus
            totalSeconds = focusDuration
        }
        updateTimeRemaining()
    }
    
    private func updateTimeRemaining() {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        timeRemaining = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func saveSessionCount() {
        DispatchQueue.global(qos: .background).async {
            UserDefaults.standard.set(self.dailySessionsCompleted, forKey: self.userDefaultsKey)
        }
    }
    
    private func loadSessionCount() {
        dailySessionsCompleted = UserDefaults.standard.integer(forKey: userDefaultsKey)
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(sessionType.rawValue) Complete!"
        content.sound = .default
        
        switch sessionType {
        case .focus:
            content.body = "Time for a well-deserved break. 👍"
        case .shortBreak, .longBreak:
            content.body = "Break's over! Let's get back to it. 💪"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(totalSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
