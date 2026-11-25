import Foundation
@testable import MeterInspect

@MainActor
final class MockInspectionRepository: InspectionRepository {

    private(set) var inspections: [Inspection] = []

    var shouldThrowError = false

    func add(_ inspection: Inspection) async throws {
        try checkForError()
        inspections.append(inspection)
    }

    func fetch(by id: UUID) async throws -> Inspection? {
        try checkForError()
        return inspections.first { $0.id == id }
    }

    func fetchAll() async throws -> [Inspection] {
        try checkForError()
        return inspections
    }

    func update(_ inspection: Inspection) async throws {
        try checkForError()

        guard let index = inspections.firstIndex(where: { $0.id == inspection.id }) else {
            return
        }

        inspections[index] = inspection
    }

    func delete(by id: UUID) async throws {
        try checkForError()
        inspections.removeAll { $0.id == id }
    }

    func seed(_ inspections: [Inspection]) {
        self.inspections = inspections
    }

    private func checkForError() throws {
        if shouldThrowError {
            throw MockRepositoryError.simulatedFailure
        }
    }
}

enum MockRepositoryError: Error {
    case simulatedFailure
}

