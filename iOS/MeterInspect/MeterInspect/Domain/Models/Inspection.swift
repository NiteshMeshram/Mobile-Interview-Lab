import Foundation

struct Inspection: Identifiable {
    let id: UUID
    let meterID: UUID
    var readings: Decimal
    let inspectionDate: Date
    var videoFilePath: String?
    var status: InspectionStatus
    var metadataSyncStatus: MetadataSyncStatus = .pending
    var videoSyncStatus: VideoSyncStatus = .notRequired

    mutating func transition(to newStatus: InspectionStatus) throws {
        guard status.canTransition(to: newStatus) else {
            throw InspectionError.invalidStatusTransition(
                from: status,
                to: newStatus
            )
        }

        status = newStatus
    }
}
