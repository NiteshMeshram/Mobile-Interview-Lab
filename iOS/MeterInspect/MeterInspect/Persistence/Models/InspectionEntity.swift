import Foundation
import SwiftData

@Model
final class InspectionEntity {
    @Attribute(.unique) var id: UUID

    var meterID: UUID
    var readings: Decimal
    var inspectionDate: Date
    var videoFilePath: String?
    var status: String
    var metadataSyncStatus: String
    var videoSyncStatus: String

    init(
        id: UUID,
        meterID: UUID,
        readings: Decimal,
        inspectionDate: Date,
        videoFilePath: String?,
        status: String,
        metadataSyncStatus: String,
        videoSyncStatus: String
    ) {
        self.id = id
        self.meterID = meterID
        self.readings = readings
        self.inspectionDate = inspectionDate
        self.videoFilePath = videoFilePath
        self.status = status
        self.metadataSyncStatus = metadataSyncStatus
        self.videoSyncStatus = videoSyncStatus
    }
}
