
import Foundation

@MainActor
protocol MeterRepository {

    // MARK: - Actions
    func add(_ meter: Meter) async throws
    func fetch(by id: UUID) async throws -> Meter?
    func fetchAll() async throws -> [Meter]
    func fetchAll(for customerID: UUID) async throws -> [Meter]
    func update(_ meter: Meter) async throws
    func delete(by id: UUID) async throws
}
