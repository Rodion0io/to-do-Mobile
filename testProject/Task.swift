import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var description: String
    var isCompleted: Bool
}
