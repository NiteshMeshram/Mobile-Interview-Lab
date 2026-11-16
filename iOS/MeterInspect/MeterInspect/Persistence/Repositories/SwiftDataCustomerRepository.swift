import Foundation
import SwiftData

@MainActor
final class SwiftDataCustomerRepository: CustomerRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func add(_ customer: Customer) async throws {
        let entity = CustomerMapper.toEntity(customer)
        modelContext.insert(entity)
        try modelContext.save()
    }

    func fetch(by id: UUID) async throws -> Customer? {
        let descriptor = FetchDescriptor<CustomerEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return CustomerMapper.toDomain(entity)
    }

    func fetchAll() async throws -> [Customer] {
        let descriptor = FetchDescriptor<CustomerEntity>(
            sortBy: [SortDescriptor(\.name)]
        )

        let entities = try modelContext.fetch(descriptor)
        return entities.map { CustomerMapper.toDomain($0) }
    }

    func update(_ customer: Customer) async throws {
        let customerID = customer.id

        let descriptor = FetchDescriptor<CustomerEntity>(
            predicate: #Predicate { $0.id == customerID }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return
        }

        entity.name = customer.name
        entity.email = customer.email
        entity.address = customer.address

        try modelContext.save()
    }

    func delete(by id: UUID) async throws {
        let descriptor = FetchDescriptor<CustomerEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(entity)
        try modelContext.save()
    }
}

