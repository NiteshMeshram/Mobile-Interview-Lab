import Foundation

enum InspectionStatus: String, Codable {
    case draft = "Draft"
    case completed = "Completed"
    case pendingSync = "Pending Sync"
    case syncing = "Syncing"
    case syncFailed = "Sync Failed"
    case synced = "Synced"
}


extension InspectionStatus {
    func canTransition(to newStatus: InspectionStatus) -> Bool {
        switch (self, newStatus) {
        case (.draft, .completed),
            (.completed, .pendingSync),
            (.pendingSync, .syncing),
            (.syncing, .synced),
            (.syncing, .syncFailed),
            (.syncFailed, .pendingSync):
            return true

        default:
            return false
        }
    }
}
