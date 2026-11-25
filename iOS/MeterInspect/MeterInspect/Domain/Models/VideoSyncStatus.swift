import Foundation

enum VideoSyncStatus: String, Codable {
    case notRequired = "Not Required"
    case pending = "Pending"
    case uploading = "Uploading"
    case failed = "Failed"
    case uploaded = "Uploaded"
}

