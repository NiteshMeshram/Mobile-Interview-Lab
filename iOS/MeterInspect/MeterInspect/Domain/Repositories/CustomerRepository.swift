
import Foundation

@MainActor
protocol CustomerRepository {
    func add(_ customer: Customer) async throws
    func fetch(by id: UUID) async throws -> Customer?
    func fetchAll() async throws -> [Customer]
    func update(_ customer: Customer) async throws
    func delete(by id: UUID) async throws
}
