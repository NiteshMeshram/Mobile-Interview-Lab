import Foundation

@MainActor
protocol InspectionRepository {
    func add(_ inspection: Inspection) async throws
    func fetch(by id: UUID) async throws -> Inspection?
    func fetchAll() async throws -> [Inspection]
    func update(_ inspection: Inspection) async throws
    func delete(by id: UUID) async throws
}
