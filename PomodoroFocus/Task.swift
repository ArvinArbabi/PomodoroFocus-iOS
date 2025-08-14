import Foundation

// This struct defines the data structure for a single task.
// Identifiable: Allows SwiftUI to uniquely identify tasks in a list.
// Codable: Allows us to easily convert this object to and from JSON for saving to storage.
// Hashable: Makes the object usable in certain collection types and for identifying changes.
struct Task: Identifiable, Codable, Hashable {
    var id = UUID() // A unique ID for each task.
    var name: String
    var pomodorosNeeded: Int
}
