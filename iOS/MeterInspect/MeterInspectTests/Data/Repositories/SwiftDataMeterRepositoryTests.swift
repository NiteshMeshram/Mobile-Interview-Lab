import Foundation
import SwiftData
import Testing
@testable import MeterInspect

@MainActor
struct SwiftDataMeterRepositoryTests {

    // MARK: - Test Helpers

    private func makeRepository() throws -> (
        SwiftDataMeterRepository,
        ModelContainer
    ) {
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: MeterEntity.self,
            configurations: configuration
        )

        let repository = SwiftDataMeterRepository(
            modelContext: container.mainContext
        )

        return (repository, container)
    }

    private func makeMeter(
        id: UUID = UUID(),
        meterNumber: String = "MTR-1001",
        customerID: UUID = UUID(),
        meterType: String = "Single Phase"
    ) -> Meter {
        Meter(
            id: id,
            meterNumber: meterNumber,
            customerID: customerID,
            meterType: meterType
        )
    }

    // MARK: - Add and Fetch

    @Test
    func addAndFetchMeter() async throws {
        let (repository, container) = try makeRepository()
        let meter = makeMeter()

        try await repository.add(meter)

        let result = try await repository.fetch(by: meter.id)

        #expect(result?.id == meter.id)
        #expect(result?.meterNumber == meter.meterNumber)
        #expect(result?.customerID == meter.customerID)
        #expect(result?.meterType == meter.meterType)

        withExtendedLifetime(container) {}
    }

    @Test
    func fetchAllMeters() async throws {
        let (repository, container) = try makeRepository()

        let first = makeMeter(meterNumber: "MTR-1001")
        let second = makeMeter(meterNumber: "MTR-1002")

        try await repository.add(first)
        try await repository.add(second)

        let result = try await repository.fetchAll()

        #expect(result.count == 2)

        withExtendedLifetime(container) {}
    }

    @Test
    func fetchReturnsNilForMissingMeter() async throws {
        let (repository, container) = try makeRepository()

        let result = try await repository.fetch(by: UUID())

        #expect(result == nil)

        withExtendedLifetime(container) {}
    }

    @Test
    func fetchAllReturnsEmptyArrayWhenNoMetersExist() async throws {
        let (repository, container) = try makeRepository()

        let result = try await repository.fetchAll()

        #expect(result.isEmpty)

        withExtendedLifetime(container) {}
    }

    // MARK: - Sorting

    @Test
    func fetchAllSortsMetersByMeterNumber() async throws {
        let (repository, container) = try makeRepository()

        let third = makeMeter(meterNumber: "MTR-1003")
        let first = makeMeter(meterNumber: "MTR-1001")
        let second = makeMeter(meterNumber: "MTR-1002")

        try await repository.add(third)
        try await repository.add(first)
        try await repository.add(second)

        let result = try await repository.fetchAll()

        #expect(result.count == 3)
        #expect(result[0].meterNumber == "MTR-1001")
        #expect(result[1].meterNumber == "MTR-1002")
        #expect(result[2].meterNumber == "MTR-1003")

        withExtendedLifetime(container) {}
    }

    // MARK: - Customer Filtering

    @Test
    func fetchAllForCustomerReturnsOnlyMatchingMeters() async throws {
        let (repository, container) = try makeRepository()

        let customerID = UUID()
        let anotherCustomerID = UUID()

        let first = makeMeter(
            meterNumber: "MTR-1001",
            customerID: customerID
        )

        let second = makeMeter(
            meterNumber: "MTR-1002",
            customerID: customerID
        )

        let third = makeMeter(
            meterNumber: "MTR-2001",
            customerID: anotherCustomerID
        )

        try await repository.add(first)
        try await repository.add(second)
        try await repository.add(third)

        let result = try await repository.fetchAll(
            for: customerID
        )

        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.customerID == customerID })

        withExtendedLifetime(container) {}
    }

    @Test
    func fetchAllForCustomerReturnsEmptyArrayWhenNoMetersMatch()
    async throws {
        let (repository, container) = try makeRepository()

        let meter = makeMeter()
        try await repository.add(meter)

        let result = try await repository.fetchAll(for: UUID())

        #expect(result.isEmpty)

        withExtendedLifetime(container) {}
    }

    @Test
    func fetchAllForCustomerSortsMetersByMeterNumber() async throws {
        let (repository, container) = try makeRepository()

        let customerID = UUID()

        let third = makeMeter(
            meterNumber: "MTR-1003",
            customerID: customerID
        )

        let first = makeMeter(
            meterNumber: "MTR-1001",
            customerID: customerID
        )

        let second = makeMeter(
            meterNumber: "MTR-1002",
            customerID: customerID
        )

        try await repository.add(third)
        try await repository.add(first)
        try await repository.add(second)

        let result = try await repository.fetchAll(for: customerID)

        #expect(result.count == 3)
        #expect(result[0].meterNumber == "MTR-1001")
        #expect(result[1].meterNumber == "MTR-1002")
        #expect(result[2].meterNumber == "MTR-1003")

        withExtendedLifetime(container) {}
    }

    // MARK: - Update

    @Test
    func updateMeter() async throws {
        let (repository, container) = try makeRepository()

        let meter = makeMeter()
        try await repository.add(meter)

        let updatedMeter = Meter(
            id: meter.id,
            meterNumber: "MTR-UPDATED",
            customerID: UUID(),
            meterType: "Three Phase"
        )

        try await repository.update(updatedMeter)

        let result = try await repository.fetch(by: meter.id)

        #expect(result?.id == meter.id)
        #expect(result?.meterNumber == updatedMeter.meterNumber)
        #expect(result?.customerID == updatedMeter.customerID)
        #expect(result?.meterType == updatedMeter.meterType)

        withExtendedLifetime(container) {}
    }

    @Test
    func updateDoesNothingWhenMeterDoesNotExist() async throws {
        let (repository, container) = try makeRepository()
        let meter = makeMeter()

        try await repository.update(meter)

        let result = try await repository.fetch(by: meter.id)

        #expect(result == nil)

        withExtendedLifetime(container) {}
    }

    // MARK: - Delete

    @Test
    func deleteMeter() async throws {
        let (repository, container) = try makeRepository()
        let meter = makeMeter()

        try await repository.add(meter)
        try await repository.delete(by: meter.id)

        let result = try await repository.fetch(by: meter.id)

        #expect(result == nil)

        withExtendedLifetime(container) {}
    }

    @Test
    func deleteDoesNothingWhenMeterDoesNotExist() async throws {
        let (repository, container) = try makeRepository()

        try await repository.delete(by: UUID())

        let result = try await repository.fetchAll()

        #expect(result.isEmpty)

        withExtendedLifetime(container) {}
    }

    // MARK: - Persistence

    private func makeDiskBackedContainer(
        at storeURL: URL
    ) throws -> ModelContainer {
        let schema = Schema([MeterEntity.self])

        let configuration = ModelConfiguration(
            "MeterPersistenceTest",
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private func saveMeter(
        _ meter: Meter,
        at storeURL: URL
    ) async throws {
        let container = try makeDiskBackedContainer(at: storeURL)

        let repository = SwiftDataMeterRepository(
            modelContext: container.mainContext
        )

        try await repository.add(meter)
    }

    @Test
    func meterPersistsAfterReopeningContainer() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let storeURL = directory.appendingPathComponent(
            "MeterInspect.store"
        )

        let meter = makeMeter()

        // First container: save meter.
        try await saveMeter(meter, at: storeURL)

        // Second container: reopen the same persistent store.
        let reopenedContainer = try makeDiskBackedContainer(
            at: storeURL
        )

        let reopenedRepository = SwiftDataMeterRepository(
            modelContext: reopenedContainer.mainContext
        )

        let result = try await reopenedRepository.fetch(by: meter.id)

        #expect(result?.id == meter.id)
        #expect(result?.meterNumber == meter.meterNumber)
        #expect(result?.customerID == meter.customerID)
        #expect(result?.meterType == meter.meterType)
    }
}

