
import Foundation
@testable import MeterInspect

@MainActor
final class MockCustomerRepository: CustomerRepository {

    private(set) var customers: [Customer] = []

    var shouldThrowError = false

    func add(_ customer: Customer) async throws {
        try checkForError()
        customers.append(customer)
    }

    func fetch(by id: UUID) async throws -> Customer? {
        try checkForError()
        return customers.first { $0.id == id }
    }

    func fetchAll() async throws -> [Customer] {
        try checkForError()
        return customers
    }

    func update(_ customer: Customer) async throws {
        try checkForError()

        guard let index = customers.firstIndex(where: { $0.id == customer.id }) else {
            return
        }

        customers[index] = customer
    }

    func delete(by id: UUID) async throws {
        try checkForError()
        customers.removeAll { $0.id == id }
    }

    func seed(_ customers: [Customer]) {
        self.customers = customers
    }

    private func checkForError() throws {
        if shouldThrowError {
            throw MockRepositoryError.simulatedFailure
        }
    }
}

