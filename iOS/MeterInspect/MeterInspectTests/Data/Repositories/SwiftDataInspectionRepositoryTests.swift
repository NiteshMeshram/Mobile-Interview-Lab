import Foundation
import SwiftData
import Testing
@testable import MeterInspect

@MainActor
struct SwiftDataInspectionRepositoryTests {

    private func makeRepository() throws -> (
        SwiftDataInspectionRepository,
        ModelContainer
    ) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(
            for: InspectionEntity.self,
            configurations: configuration
        )

        let repository = SwiftDataInspectionRepository(
            modelContext: container.mainContext
        )

        return (repository, container)
    }

    private func makeInspection() -> Inspection {
        Inspection(
            id: UUID(),
            meterID: UUID(),
            readings: 1250.50,
            inspectionDate: Date(),
            videoFilePath: nil,
            status: .pendingSync
        )
    }

    @Test
    func addAndFetchInspection() async throws {
        let (repository, container) = try makeRepository()
        let inspection = makeInspection()

        try await repository.add(inspection)

        let result = try await repository.fetch(by: inspection.id)

        #expect(result?.id == inspection.id)
        #expect(result?.readings == inspection.readings)
        #expect(result?.status == inspection.status)
        withExtendedLifetime(container) {}
    }

    @Test
    func fetchAllInspections() async throws {
        let (repository, container) = try makeRepository()

        let first = makeInspection()
        let second = makeInspection()

        try await repository.add(first)
        try await repository.add(second)

        let result = try await repository.fetchAll()

        #expect(result.count == 2)
        withExtendedLifetime(container) {}
    }

    @Test
    func updateInspection() async throws {
        let (repository, container) = try makeRepository()
        var inspection = makeInspection()

        try await repository.add(inspection)

        inspection.readings = 1500.75
        inspection.status = .completed

        try await repository.update(inspection)

        let result = try await repository.fetch(by: inspection.id)

        #expect(result?.readings == 1500.75)
        #expect(result?.status == .completed)
        withExtendedLifetime(container) {}
    }

    @Test
    func deleteInspection() async throws {
        let (repository, container) = try makeRepository()
        let inspection = makeInspection()

        try await repository.add(inspection)
        try await repository.delete(by: inspection.id)

        let result = try await repository.fetch(by: inspection.id)

        #expect(result == nil)
        withExtendedLifetime(container) {}
    }

    private func makeDiskBackedContainer(at storeURL: URL) throws -> ModelContainer {
        let schema = Schema([
            InspectionEntity.self
        ])

        let configuration = ModelConfiguration(
            "PersistenceTest",
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private func saveInspection(
        _ inspection: Inspection,
        at storeURL: URL
    ) async throws {
        let container = try makeDiskBackedContainer(at: storeURL)

        let repository = SwiftDataInspectionRepository(
            modelContext: container.mainContext
        )

        try await repository.add(inspection)
    }

    @Test
    func inspectionPersistsAfterReopeningContainer() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let storeURL = directory.appendingPathComponent("MeterInspect.store")
        let inspection = makeInspection()

        // First container: save inspection.
        try await saveInspection(inspection, at: storeURL)

        // Second container: reopen the same persistent store.
        let reopenedContainer = try makeDiskBackedContainer(at: storeURL)

        let reopenedRepository = SwiftDataInspectionRepository(
            modelContext: reopenedContainer.mainContext
        )

        let result = try await reopenedRepository.fetch(by: inspection.id)

        #expect(result?.id == inspection.id)
        #expect(result?.meterID == inspection.meterID)
        #expect(result?.readings == inspection.readings)
        #expect(result?.status == inspection.status)
    }
}
