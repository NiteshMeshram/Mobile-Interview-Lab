import Foundation
import SwiftData
import Testing
@testable import MeterInspect

@MainActor
struct SampleDataSeederTests {

    // MARK: - Test Helpers

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            CustomerEntity.self,
            MeterEntity.self
        ])

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private func fetchCustomers(
        from context: ModelContext
    ) throws -> [CustomerEntity] {
        try context.fetch(FetchDescriptor<CustomerEntity>())
    }

    private func fetchMeters(
        from context: ModelContext
    ) throws -> [MeterEntity] {
        try context.fetch(FetchDescriptor<MeterEntity>())
    }

    // MARK: - Initial Seeding

    @Test
    func seedIfNeededSeedsCustomersAndMetersWhenDatabaseIsEmpty()
    throws {
        let container = try makeContainer()
        let context = container.mainContext

        try SampleDataSeeder.seedIfNeeded(context: context)

        let customers = try fetchCustomers(from: context)
        let meters = try fetchMeters(from: context)

        #expect(customers.count == 2)
        #expect(meters.count == 3)
    }

    // MARK: - Customer Data

    @Test
    func seedIfNeededCreatesExpectedCustomers() throws {
        let container = try makeContainer()
        let context = container.mainContext

        try SampleDataSeeder.seedIfNeeded(context: context)

        let customers = try fetchCustomers(from: context)

        let rahul = customers.first {
            $0.email == "rahul@example.com"
        }

        let priya = customers.first {
            $0.email == "priya@example.com"
        }

        #expect(rahul?.name == "Rahul Sharma")
        #expect(rahul?.address == "Nerul, Navi Mumbai")

        #expect(priya?.name == "Priya Patel")
        #expect(priya?.address == "Vashi, Navi Mumbai")
    }

    // MARK: - Meter Data

    @Test
    func seedIfNeededCreatesExpectedMetersAndCustomerRelationships()
    throws {
        let container = try makeContainer()
        let context = container.mainContext

        try SampleDataSeeder.seedIfNeeded(context: context)

        let customers = try fetchCustomers(from: context)
        let meters = try fetchMeters(from: context)

        let rahul = customers.first {
            $0.email == "rahul@example.com"
        }

        let priya = customers.first {
            $0.email == "priya@example.com"
        }

        let rahulMeters = meters.filter {
            $0.customerID == rahul?.id
        }

        let priyaMeters = meters.filter {
            $0.customerID == priya?.id
        }

        let meter1001 = meters.first {
            $0.meterNumber == "MTR-1001"
        }

        let meter1002 = meters.first {
            $0.meterNumber == "MTR-1002"
        }

        let meter2001 = meters.first {
            $0.meterNumber == "MTR-2001"
        }

        #expect(meter1001?.meterType == "Single Phase")
        #expect(meter1002?.meterType == "Three Phase")
        #expect(meter2001?.meterType == "Single Phase")

        #expect(rahulMeters.count == 2)
        #expect(priyaMeters.count == 1)
    }

    // MARK: - Idempotency

    @Test
    func seedIfNeededDoesNotDuplicateDataWhenCalledMultipleTimes()
    throws {
        let container = try makeContainer()
        let context = container.mainContext

        try SampleDataSeeder.seedIfNeeded(context: context)

        let initialCustomers = try fetchCustomers(from: context)
        let initialMeters = try fetchMeters(from: context)

        try SampleDataSeeder.seedIfNeeded(context: context)
        try SampleDataSeeder.seedIfNeeded(context: context)

        let finalCustomers = try fetchCustomers(from: context)
        let finalMeters = try fetchMeters(from: context)

        #expect(initialCustomers.count == 2)
        #expect(initialMeters.count == 3)

        #expect(finalCustomers.count == 2)
        #expect(finalMeters.count == 3)
    }

    // MARK: - Existing Data

    @Test
    func seedIfNeededDoesNotOverwriteExistingCustomerData()
    throws {
        let container = try makeContainer()
        let context = container.mainContext

        let existingCustomer = Customer(
            id: UUID(),
            name: "Existing Customer",
            email: "existing@example.com",
            address: "Mumbai"
        )

        context.insert(CustomerMapper.toEntity(existingCustomer))
        try context.save()

        try SampleDataSeeder.seedIfNeeded(context: context)

        let customers = try fetchCustomers(from: context)
        let meters = try fetchMeters(from: context)

        #expect(customers.count == 1)
        #expect(customers.first?.id == existingCustomer.id)
        #expect(customers.first?.name == "Existing Customer")
        #expect(customers.first?.email == "existing@example.com")

        // Seeder returns early when any customer already exists.
        #expect(meters.isEmpty)
    }
}

