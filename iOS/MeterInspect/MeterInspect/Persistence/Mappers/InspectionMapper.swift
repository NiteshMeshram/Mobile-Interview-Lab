//
import Foundation
import UIKit

struct InspectionMapper {
    static func toEntity(_ inspection: Inspection) -> InspectionEntity {
        // MARK: - Domain to Persistence
        InspectionEntity(
            id: inspection.id,
            meterID: inspection.meterID,
            readings: inspection.readings,
            inspectionDate: inspection.inspectionDate,
            videoFilePath: inspection.videoFilePath,
            status: inspection.status.rawValue
        )
    }

    // MARK: - Persistence to Domain

    static func toDomain(_ entity: InspectionEntity) -> Inspection {
        Inspection(
            id: entity.id,
            meterID: entity.meterID,
            readings: entity.readings,
            inspectionDate: entity.inspectionDate,
            videoFilePath: entity.videoFilePath,
            status: InspectionStatus(rawValue: entity.status) ?? .draft
        )
    }
}

