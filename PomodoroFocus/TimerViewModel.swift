import Foundation
import Combine
import UserNotifications

// The enum remains the same. We'll rename .focus to Pomodoro in the UI.
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
    
    // MARK: - Timer Configuration (as per PRD)
    private let focusDuration: Int = 25 * 60 // 25 minutes
    private let shortBreakDuration: Int = 5 * 60 // 5 minutes
    private let longBreakDuration: Int = 15 * 60 // 15 minutes
    private let pomodorosPerCycle: Int = 4
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var totalSeconds: Int = 0
    private var pomodoroCycleCount: Int = 0
    private let userDefaultsKey = "dailySessionsCompleted"

    init() {
        self.totalSeconds = focusDuration
        loadSessionCount()
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

    // --- NEW FUNCTION ---
    // This function allows the UI buttons to manually change the session.
    func selectSession(type: SessionType) {
        pause() // Stop any running timer
        sessionType = type // Set the new session type

        switch type {
        case .focus:
            totalSeconds = focusDuration
        case .shortBreak:
            totalSeconds = shortBreakDuration
        case .longBreak:
            totalSeconds = longBreakDuration
        }
        
        updateTimeRemaining() // Update the display immediately
    }

    // MARK: - Timer Logic
    private func start() {
        timerActive = true
        // Schedule a timer that fires every second.
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
    
    // MARK: - Helper Functions
    private func updateTimeRemaining() {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        timeRemaining = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Data Persistence
    private func saveSessionCount() {
        DispatchQueue.global(qos: .background).async {
            UserDefaults.standard.set(self.dailySessionsCompleted, forKey: self.userDefaultsKey)
        }
    }
    
    private func loadSessionCount() {
        dailySessionsCompleted = UserDefaults.standard.integer(forKey: userDefaultsKey)
    }
    
    // MARK: - Notification Logic
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
