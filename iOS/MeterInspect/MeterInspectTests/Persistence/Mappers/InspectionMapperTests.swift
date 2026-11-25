import Foundation
import Testing
@testable import MeterInspect

struct InspectionMapperTests {

    // MARK: - Domain to Persistence

    @Test
    func toEntity_mapsAllInspectionProperties() {
        let inspectionID = UUID()
        let meterID = UUID()
        let inspectionDate = Date.now

        let inspection = Inspection(
            id: inspectionID,
            meterID: meterID,
            readings: Decimal(string: "1450.75")!,
            inspectionDate: inspectionDate,
            videoFilePath: "/videos/meter-inspection.mp4",
            status: .pendingSync
        )

        let entity = InspectionMapper.toEntity(inspection)

        #expect(entity.id == inspectionID)
        #expect(entity.meterID == meterID)
        #expect(entity.readings == Decimal(string: "1450.75")!)
        #expect(entity.inspectionDate == inspectionDate)
        #expect(entity.videoFilePath == "/videos/meter-inspection.mp4")
        #expect(entity.status == InspectionStatus.pendingSync.rawValue)
    }

    @Test
    func toEntity_mapsNilVideoFilePath() {
        let inspection = Inspection(
            id: UUID(),
            meterID: UUID(),
            readings: Decimal(string: "1200.50")!,
            inspectionDate: .now,
            videoFilePath: nil,
            status: .draft
        )

        let entity = InspectionMapper.toEntity(inspection)

        #expect(entity.videoFilePath == nil)
    }

    // MARK: - Persistence to Domain

    @Test
    func toDomain_mapsAllEntityProperties() {
        let inspectionID = UUID()
        let meterID = UUID()
        let inspectionDate = Date.now

        let entity = InspectionEntity(
            id: inspectionID,
            meterID: meterID,
            readings: Decimal(string: "1450.75")!,
            inspectionDate: inspectionDate,
            videoFilePath: "/videos/meter-inspection.mp4",
            status: InspectionStatus.synced.rawValue
        )

        let inspection = InspectionMapper.toDomain(entity)

        #expect(inspection.id == inspectionID)
        #expect(inspection.meterID == meterID)
        #expect(inspection.readings == Decimal(string: "1450.75")!)
        #expect(inspection.inspectionDate == inspectionDate)
        #expect(inspection.videoFilePath == "/videos/meter-inspection.mp4")
        #expect(inspection.status == .synced)
    }

    @Test
    func toDomain_mapsNilVideoFilePath() {
        let entity = InspectionEntity(
            id: UUID(),
            meterID: UUID(),
            readings: Decimal(string: "1000.00")!,
            inspectionDate: .now,
            videoFilePath: nil,
            status: InspectionStatus.draft.rawValue
        )

        let inspection = InspectionMapper.toDomain(entity)

        #expect(inspection.videoFilePath == nil)
        #expect(inspection.status == .draft)
    }

    // MARK: - Invalid Status Handling

    @Test
    func toDomain_defaultsToDraftForUnknownStatus() {
        let entity = InspectionEntity(
            id: UUID(),
            meterID: UUID(),
            readings: Decimal(string: "1500.00")!,
            inspectionDate: .now,
            videoFilePath: nil,
            status: "unknownStatus"
        )

        let inspection = InspectionMapper.toDomain(entity)

        #expect(inspection.status == .draft)
    }

    // MARK: - Round Trip

    @Test
    func roundTrip_preservesInspectionProperties() {
        let original = Inspection(
            id: UUID(),
            meterID: UUID(),
            readings: Decimal(string: "1750.25")!,
            inspectionDate: .now,
            videoFilePath: "/videos/inspection.mp4",
            status: .syncFailed
        )

        let entity = InspectionMapper.toEntity(original)
        let restored = InspectionMapper.toDomain(entity)

        #expect(restored.id == original.id)
        #expect(restored.meterID == original.meterID)
        #expect(restored.readings == original.readings)
        #expect(restored.inspectionDate == original.inspectionDate)
        #expect(restored.videoFilePath == original.videoFilePath)
        #expect(restored.status == original.status)
    }
}

