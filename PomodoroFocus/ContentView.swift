import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = TimerViewModel()
    
    // This @State variable will control whether the settings sheet is visible.
    @State private var isShowingSettings = false

    private let focusColor = Color.red.opacity(0.9)
    private let shortBreakColor = Color(red: 135/255, green: 206/255, blue: 235/255) // Sky Blue
    private let longBreakColor = Color(red: 152/255, green: 251/255, blue: 152/255) // Pastel Green

    // We update the background color logic to check for dark mode first.
    private var backgroundColor: Color {
        // If dark mode is enabled, always return black.
        if viewModel.isDarkModeEnabled {
            return Color.black
        }
        
        // Otherwise, return the color based on the session type.
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

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut, value: viewModel.sessionType)
                .animation(.easeInOut, value: viewModel.isDarkModeEnabled) // Also animate dark mode change
            
            VStack(spacing: 20) {
                
                // MARK: - Top Bar with Settings Button
                HStack {
                    // This is the container for our session selection buttons.
                    HStack {
                        Button("Pomodoro") { viewModel.selectSession(type: .focus) }
                            .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .focus))
                        
                        Button("Short Rest") { viewModel.selectSession(type: .shortBreak) }
                            .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .shortBreak))
                        
                        Button("Long Rest") { viewModel.selectSession(type: .longBreak) }
                            .buttonStyle(SessionButtonStyle(isSelected: viewModel.sessionType == .longBreak))
                    }
                    
                    Spacer() // Pushes the settings button to the far right.
                    
                    // The new settings button.
                    Button(action: {
                        isShowingSettings = true // This will present our settings sheet.
                    }) {
                        Image(systemName: "line.horizontal.3") // The "3 bar" icon.
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // MARK: - Timer Display
                Text(viewModel.timeRemaining)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()

                // MARK: - Control Button
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
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .foregroundColor(buttonAccentColor)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                // MARK: - Daily Progress
                Text("Today's Pomodoros: \(viewModel.dailySessionsCompleted)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 40)
            }
        }
        // This modifier presents a "sheet" (a view that slides up from the bottom)
        // when the `isShowingSettings` variable becomes true.
        .sheet(isPresented: $isShowingSettings) {
            // Here we specify which view to show: our new SettingsView.
            // We pass our viewModel into it so it can read and write the dark mode setting.
            SettingsView(viewModel: viewModel)
        }
    }
}

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
