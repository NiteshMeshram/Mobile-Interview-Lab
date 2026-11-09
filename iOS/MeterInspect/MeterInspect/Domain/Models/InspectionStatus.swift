import Foundation

enum InspectionStatus: String, Codable {
    case draft = "Draft"
    case completed = "Completed"
    case pendingSync = "Pending Sync"
    case syncing = "Syncing"
    case syncFailed = "Sync Failed"
    case synced = "Synced"
}

