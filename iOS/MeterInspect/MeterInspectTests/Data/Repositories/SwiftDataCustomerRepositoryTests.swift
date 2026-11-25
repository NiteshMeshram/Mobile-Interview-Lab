
import Foundation
import SwiftData
import Testing
@testable import MeterInspect

@MainActor
struct SwiftDataCustomerRepositoryTests {

    // MARK: - Test Helpers

    private func makeRepository() throws -> (
        SwiftDataCustomerRepository,
        ModelContainer
    ) {
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: CustomerEntity.self,
            configurations: configuration
        )

        let repository = SwiftDataCustomerRepository(
            modelContext: container.mainContext
        )

        return (repository, container)
    }

    private func makeCustomer(
        id: UUID = UUID(),
        name: String = "Rahul Sharma",
        email: String = "rahul@example.com",
        address: String = "Nerul, Navi Mumbai"
    ) -> Customer {
        Customer(
            id: id,
            name: name,
            email: email,
            address: address
        )
    }

    // MARK: - Add and Fetch

    @Test
    func addAndFetchCustomer() async throws {
        let (repository, container) = try makeRepository()
        let customer = makeCustomer()

        try await repository.add(customer)

        let result = try await repository.fetch(by: customer.id)

        #expect(result?.id == customer.id)
        #expect(result?.name == customer.name)
        #expect(result?.email == customer.email)
        #expect(result?.address == customer.address)

        withExtendedLifetime(container) {}
    }

    @Test
    func fetchAllCustomers() async throws {
        let (repository, container) = try makeRepository()

        let first = makeCustomer(name: "Rahul Sharma")
        let second = makeCustomer(
            name: "Priya Patel",
            email: "priya@example.com",
            address: "Vashi, Navi Mumbai"
        )

        try await repository.add(first)
        try await repository.add(second)

        let result = try await repository.fetchAll()

        #expect(result.count == 2)

        withExtendedLifetime(container) {}
    }

    @Test
    func fetchReturnsNilForMissingCustomer() async throws {
        let (repository, container) = try makeRepository()

        let result = try await repository.fetch(by: UUID())

        #expect(result == nil)

        withExtendedLifetime(container) {}
    }

    @Test
    func fetchAllReturnsEmptyArrayWhenNoCustomersExist() async throws {
        let (repository, container) = try makeRepository()

        let result = try await repository.fetchAll()

        #expect(result.isEmpty)

        withExtendedLifetime(container) {}
    }

    // MARK: - Sorting

    @Test
    func fetchAllSortsCustomersByName() async throws {
        let (repository, container) = try makeRepository()

        let charlie = makeCustomer(name: "Charlie")
        let alice = makeCustomer(name: "Alice")
        let bob = makeCustomer(name: "Bob")

        // Insert in a different order from the expected result.
        try await repository.add(charlie)
        try await repository.add(alice)
        try await repository.add(bob)

        let result = try await repository.fetchAll()

        #expect(result.count == 3)
        #expect(result[0].name == "Alice")
        #expect(result[1].name == "Bob")
        #expect(result[2].name == "Charlie")

        withExtendedLifetime(container) {}
    }

    // MARK: - Update

    @Test
    func updateCustomer() async throws {
        let (repository, container) = try makeRepository()

        let customer = makeCustomer()
        try await repository.add(customer)

        let updatedCustomer = Customer(
            id: customer.id,
            name: "Rahul Kumar",
            email: "rahul.updated@example.com",
            address: "Kharghar, Navi Mumbai"
        )

        try await repository.update(updatedCustomer)

        let result = try await repository.fetch(by: customer.id)

        #expect(result?.id == customer.id)
        #expect(result?.name == updatedCustomer.name)
        #expect(result?.email == updatedCustomer.email)
        #expect(result?.address == updatedCustomer.address)

        withExtendedLifetime(container) {}
    }

    @Test
    func updateDoesNothingWhenCustomerDoesNotExist() async throws {
        let (repository, container) = try makeRepository()
        let customer = makeCustomer()

        try await repository.update(customer)

        let result = try await repository.fetch(by: customer.id)

        #expect(result == nil)

        withExtendedLifetime(container) {}
    }

    // MARK: - Delete

    @Test
    func deleteCustomer() async throws {
        let (repository, container) = try makeRepository()
        let customer = makeCustomer()

        try await repository.add(customer)
        try await repository.delete(by: customer.id)

        let result = try await repository.fetch(by: customer.id)

        #expect(result == nil)

        withExtendedLifetime(container) {}
    }

    @Test
    func deleteDoesNothingWhenCustomerDoesNotExist() async throws {
        let (repository, container) = try makeRepository()

        try await repository.delete(by: UUID())

        let result = try await repository.fetchAll()

        #expect(result.isEmpty)

        withExtendedLifetime(container) {}
    }

    // MARK: - Persistence

    private func makeDiskBackedContainer(at storeURL: URL) throws -> ModelContainer {
        let schema = Schema([CustomerEntity.self])

        let configuration = ModelConfiguration(
            "CustomerPersistenceTest",
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private func saveCustomer(
        _ customer: Customer,
        at storeURL: URL
    ) async throws {
        let container = try makeDiskBackedContainer(at: storeURL)

        let repository = SwiftDataCustomerRepository(
            modelContext: container.mainContext
        )

        try await repository.add(customer)
    }

    @Test
    func customerPersistsAfterReopeningContainer() async throws {
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

        let customer = makeCustomer()

        // First container: save customer.
        try await saveCustomer(customer, at: storeURL)

        // Second container: reopen the same persistent store.
        let reopenedContainer = try makeDiskBackedContainer(
            at: storeURL
        )

        let reopenedRepository = SwiftDataCustomerRepository(
            modelContext: reopenedContainer.mainContext
        )

        let result = try await reopenedRepository.fetch(by: customer.id)

        #expect(result?.id == customer.id)
        #expect(result?.name == customer.name)
        #expect(result?.email == customer.email)
        #expect(result?.address == customer.address)
    }
}

