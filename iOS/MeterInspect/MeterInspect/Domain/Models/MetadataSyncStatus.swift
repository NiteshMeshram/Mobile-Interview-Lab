import Foundation

enum MetadataSyncStatus: String, Codable {
    case pending = "Pending"
    case syncing = "Syncing"
    case failed = "Failed"
    case synced = "Synced"
}

