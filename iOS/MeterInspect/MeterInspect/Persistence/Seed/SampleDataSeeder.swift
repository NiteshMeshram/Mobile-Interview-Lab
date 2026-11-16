import Foundation
import SwiftData

@MainActor
enum SampleDataSeeder {

    static func seedIfNeeded(
        context: ModelContext
    ) throws {

        // Avoid inserting sample data more than once.
        let descriptor = FetchDescriptor<CustomerEntity>()
        let existingCustomers = try context.fetch(descriptor)

        guard existingCustomers.isEmpty else {
            return
        }

        let customer1 = Customer(
            id: UUID(),
            name: "Rahul Sharma",
            email: "rahul@example.com",
            address: "Nerul, Navi Mumbai"
        )

        let customer2 = Customer(
            id: UUID(),
            name: "Priya Patel",
            email: "priya@example.com",
            address: "Vashi, Navi Mumbai"
        )

        let meters = [
            Meter(
                id: UUID(),
                meterNumber: "MTR-1001",
                customerID: customer1.id,
                meterType: "Single Phase"
            ),
            Meter(
                id: UUID(),
                meterNumber: "MTR-1002",
                customerID: customer1.id,
                meterType: "Three Phase"
            ),
            Meter(
                id: UUID(),
                meterNumber: "MTR-2001",
                customerID: customer2.id,
                meterType: "Single Phase"
            )
        ]

        context.insert(CustomerMapper.toEntity(customer1))
        context.insert(CustomerMapper.toEntity(customer2))

        for meter in meters {
            context.insert(MeterMapper.toEntity(meter))
        }

        try context.save()
    }
}
