import Foundation
import SwiftData

@MainActor
final class SwiftDataInspectionRepository: InspectionRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Add

    func add(_ inspection: Inspection) async throws {
        let entity = InspectionMapper.toEntity(inspection)
        modelContext.insert(entity)
        try modelContext.save()
    }

    // MARK: - Fetch

    func fetch(by id: UUID) async throws -> Inspection? {
        let descriptor = FetchDescriptor<InspectionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return InspectionMapper.toDomain(entity)
    }

    // MARK: - Fetch All

    func fetchAll() async throws -> [Inspection] {
        let descriptor = FetchDescriptor<InspectionEntity>(
            sortBy: [SortDescriptor(\.inspectionDate, order: .reverse)]
        )

        let entities = try modelContext.fetch(descriptor)

        return entities.map {
            InspectionMapper.toDomain($0)
        }
    }

    // MARK: - Update

    func update(_ inspection: Inspection) async throws {
        let inspectionID = inspection.id

        let descriptor = FetchDescriptor<InspectionEntity>(
            predicate: #Predicate { entity in
                entity.id == inspectionID
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return
        }

        entity.meterID = inspection.meterID
        entity.readings = inspection.readings
        entity.inspectionDate = inspection.inspectionDate
        entity.videoFilePath = inspection.videoFilePath
        entity.status = inspection.status.rawValue

        try modelContext.save()
    }

    // MARK: - Delete

    func delete(by id: UUID) async throws {
        let descriptor = FetchDescriptor<InspectionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(entity)
        try modelContext.save()
    }
}

