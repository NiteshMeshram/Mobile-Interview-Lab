import Foundation
@testable import MeterInspect

@MainActor
final class MockMeterRepository: MeterRepository {

    // MARK: - Properties

    private(set) var meters: [Meter] = []
    var shouldThrowError = false

    // MARK: - Test Helper

    func seed(_ meters: [Meter]) {
        self.meters = meters
    }

    // MARK: - MeterRepository

    func add(_ meter: Meter) async throws {
        try checkForError()
        meters.append(meter)
    }

    func fetch(by id: UUID) async throws -> Meter? {
        try checkForError()
        return meters.first { $0.id == id }
    }

    func fetchAll() async throws -> [Meter] {
        try checkForError()
        return meters
    }

    func fetchAll(for customerID: UUID) async throws -> [Meter] {
        try checkForError()
        return meters.filter { $0.customerID == customerID }
    }

    func update(_ meter: Meter) async throws {
        try checkForError()

        guard let index = meters.firstIndex(where: { $0.id == meter.id }) else {
            return
        }

        meters[index] = meter
    }

    func delete(by id: UUID) async throws {
        try checkForError()
        meters.removeAll { $0.id == id }
    }

    // MARK: - Private Helpers

    private func checkForError() throws {
        if shouldThrowError {
            throw MockRepositoryError.simulatedFailure
        }
    }
}

