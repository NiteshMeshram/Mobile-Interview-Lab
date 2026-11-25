import Foundation

enum InspectionStatus: String, Codable {
    case draft = "Draft"
    case completed = "Completed"
}


extension InspectionStatus {
    func canTransition(to newStatus: InspectionStatus) -> Bool {
        switch (self, newStatus) {
        case (.draft, .completed):
            return true

        default:
            return false
        }
    }
}
