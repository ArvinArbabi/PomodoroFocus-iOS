import SwiftUI

struct ContentView: View {
    // Create the single source of truth for our view's state.
    @StateObject private var viewModel = TimerViewModel()

    // Define the new colors as requested.
    private let focusColor = Color.red.opacity(0.9)
    private let shortBreakColor = Color(red: 135/255, green: 206/255, blue: 235/255) // Sky Blue
    private let longBreakColor = Color(red: 152/255, green: 251/255, blue: 152/255) // Pastel Green

    // This computed property now provides the correct background color.
    private var backgroundColor: Color {
        switch viewModel.sessionType {
        case .focus:
            return focusColor
        case .shortBreak:
            return shortBreakColor
        case .longBreak:
            return longBreakColor
        }
    }
    
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

    var body: some View {
        ZStack {
            // The background color animates smoothly between changes.
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut, value: viewModel.sessionType)
            
            VStack(spacing: 20) {
                
                // MARK: - Session Selection Buttons
                HStack {
                    Button("Pomodoro") {
                        viewModel.selectSession(type: .focus)
                    }
                    .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .focus))
                    
                    Button("Short Rest") {
                        viewModel.selectSession(type: .shortBreak)
                    }
                    .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .shortBreak))
                    
                    Button("Long Rest") {
                        viewModel.selectSession(type: .longBreak)
                    }
                    .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .longBreak))
                }
                .padding(.top, 20)
                
                Spacer()
                
                // MARK: - Timer Display
                Text(viewModel.timeRemaining)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()

                // MARK: - Control Button
                // The "Skip" button has been removed, leaving only the Start/Pause button.
                Button(action: {
                    viewModel.startPause()
                }) {
                    HStack {
                        Image(systemName: viewModel.timerActive ? "pause.fill" : "play.fill")
                        Text(viewModel.timerActive ? "Pause" : "Start")
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal) // Give some space on the sides
                }
                .padding()
                .background(Color.white)
                .foregroundColor(buttonAccentColor)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal) // Add horizontal padding to the button itself
                
                // MARK: - Daily Progress
                Text("Today's Pomodoros: \(viewModel.dailySessionsCompleted)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 40)
            }
        }
    }
}

// Custom styling for the top session buttons
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


// Preview struct remains the same
#Preview {
    ContentView()
}
