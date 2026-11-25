import Foundation
import Testing
@testable import MeterInspect

struct CustomerMapperTests {

    // MARK: - Domain to Persistence

    @Test
    func toEntity_mapsAllCustomerProperties() {
        let customerID = UUID()

        let customer = Customer(
            id: customerID,
            name: "Rahul Sharma",
            email: "rahul@example.com",
            address: "Nerul, Navi Mumbai"
        )

        let entity = CustomerMapper.toEntity(customer)

        #expect(entity.id == customerID)
        #expect(entity.name == "Rahul Sharma")
        #expect(entity.email == "rahul@example.com")
        #expect(entity.address == "Nerul, Navi Mumbai")
    }

    // MARK: - Persistence to Domain

    @Test
    func toDomain_mapsAllEntityProperties() {
        let customerID = UUID()

        let entity = CustomerEntity(
            id: customerID,
            name: "Priya Patel",
            email: "priya@example.com",
            address: "Vashi, Navi Mumbai"
        )

        let customer = CustomerMapper.toDomain(entity)

        #expect(customer.id == customerID)
        #expect(customer.name == "Priya Patel")
        #expect(customer.email == "priya@example.com")
        #expect(customer.address == "Vashi, Navi Mumbai")
    }

    // MARK: - Round Trip

    @Test
    func roundTrip_preservesCustomerProperties() {
        let original = Customer(
            id: UUID(),
            name: "Rahul Sharma",
            email: "rahul@example.com",
            address: "Nerul, Navi Mumbai"
        )

        let entity = CustomerMapper.toEntity(original)
        let restored = CustomerMapper.toDomain(entity)

        #expect(restored.id == original.id)
        #expect(restored.name == original.name)
        #expect(restored.email == original.email)
        #expect(restored.address == original.address)
    }

    // MARK: - Empty String Values

    @Test
    func toEntity_preservesEmptyStringValues() {
        let customer = Customer(
            id: UUID(),
            name: "",
            email: "",
            address: ""
        )

        let entity = CustomerMapper.toEntity(customer)

        #expect(entity.name.isEmpty)
        #expect(entity.email.isEmpty)
        #expect(entity.address.isEmpty)
    }

    @Test
    func toDomain_preservesEmptyStringValues() {
        let entity = CustomerEntity(
            id: UUID(),
            name: "",
            email: "",
            address: ""
        )

        let customer = CustomerMapper.toDomain(entity)

        #expect(customer.name.isEmpty)
        #expect(customer.email.isEmpty)
        #expect(customer.address.isEmpty)
    }
}

