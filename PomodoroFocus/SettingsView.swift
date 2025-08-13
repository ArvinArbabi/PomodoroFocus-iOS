import SwiftUI

// This is the new view for our settings screen.
struct SettingsView: View {
    // MARK: - Properties
    
    // @ObservedObject allows this view to watch our existing ViewModel for changes.
    // It's "observed" because this view doesn't own it; it's just borrowing it from ContentView.
    @ObservedObject var viewModel: TimerViewModel
    
    // This gives us access to the environment's built-in dismiss function,
    // which we'll use to close this settings sheet.
    @Environment(\.dismiss) var dismiss

    // MARK: - Body
    var body: some View {
        // NavigationView provides a top bar for a title and buttons.
        NavigationView {
            // A Form provides standard styling for settings lists.
            Form {
                // Section provides a visually distinct group for related settings.
                Section(header: Text("Appearance")) {
                    // A Toggle is a simple on/off switch.
                    // We bind its state directly to the `isDarkModeEnabled` property in our ViewModel.
                    // The '$' creates a two-way binding, so flipping the switch instantly
                    // changes the value in the ViewModel, and the whole app reacts.
                    Toggle("Enable Dark Mode", isOn: $viewModel.isDarkModeEnabled)
                }
            }
            .navigationTitle("Settings") // Sets the title in the top bar.
            .navigationBarTitleDisplayMode(.inline) // Makes the title smaller and centered.
            .toolbar {
                // This adds a "Done" button to the top-right of the settings screen.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss() // When tapped, this closes the sheet.
                    }
                }
            }
        }
    }
}
