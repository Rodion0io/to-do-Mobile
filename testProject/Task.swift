import Foundation

struct Task: Identifiable, Codable {
    var id: UUID
    var text: String
    var isSelected: Bool
}
