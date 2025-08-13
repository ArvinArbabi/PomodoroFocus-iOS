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
    
    // --- NEW PROPERTY FOR DARK MODE ---
    // We add a new @Published property to track the dark mode state.
    @Published var isDarkModeEnabled = false {
        // This `didSet` block runs automatically whenever isDarkModeEnabled changes.
        didSet {
            // We save the new value to UserDefaults so it's remembered next time the app opens.
            UserDefaults.standard.set(isDarkModeEnabled, forKey: darkModeKey)
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
    private let darkModeKey = "isDarkModeEnabled" // Key for saving dark mode setting.

    init() {
        self.totalSeconds = focusDuration
        
        // --- LOAD SAVED SETTINGS ---
        // When the ViewModel is created, we load the saved values.
        loadSessionCount()
        isDarkModeEnabled = UserDefaults.standard.bool(forKey: darkModeKey)
        
        updateTimeRemaining()
    }
    
    // ... all other functions (startPause, skipSession, selectSession, etc.) remain exactly the same ...
    
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

    func selectSession(type: SessionType) {
        pause()
        sessionType = type

        switch type {
        case .focus:
            totalSeconds = focusDuration
        case .shortBreak:
            totalSeconds = shortBreakDuration
        case .longBreak:
            totalSeconds = longBreakDuration
        }
        
        updateTimeRemaining()
    }

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
