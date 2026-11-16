import Foundation
import SwiftData

@MainActor
final class SwiftDataMeterRepository: MeterRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func add(_ meter: Meter) async throws {
        let entity = MeterMapper.toEntity(meter)
        modelContext.insert(entity)
        try modelContext.save()
    }

    func fetch(by id: UUID) async throws -> Meter? {
        let descriptor = FetchDescriptor<MeterEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return MeterMapper.toDomain(entity)
    }

    func fetchAll() async throws -> [Meter] {
        let descriptor = FetchDescriptor<MeterEntity>(
            sortBy: [SortDescriptor(\.meterNumber)]
        )

        let entities = try modelContext.fetch(descriptor)
        return entities.map { MeterMapper.toDomain($0) }
    }

    func fetchAll(for customerID: UUID) async throws -> [Meter] {
        let descriptor = FetchDescriptor<MeterEntity>(
            predicate: #Predicate {
                $0.customerID == customerID
            },
            sortBy: [SortDescriptor(\.meterNumber)]
        )

        let entities = try modelContext.fetch(descriptor)
        return entities.map { MeterMapper.toDomain($0) }
    }

    func update(_ meter: Meter) async throws {
        let meterID = meter.id

        let descriptor = FetchDescriptor<MeterEntity>(
            predicate: #Predicate { $0.id == meterID }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return
        }

        entity.meterNumber = meter.meterNumber
        entity.customerID = meter.customerID
        entity.meterType = meter.meterType

        try modelContext.save()
    }

    func delete(by id: UUID) async throws {
        let descriptor = FetchDescriptor<MeterEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(entity)
        try modelContext.save()
    }
}

