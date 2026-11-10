import Foundation
import Combine

@MainActor
final class InspectionListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var inspections: [Inspection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let repository: InspectionRepository

    // MARK: - Initialization

    init(repository: InspectionRepository) {
        self.repository = repository
    }

    // MARK: - Actions

    func loadInspections() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            inspections = try await repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createInspection(meterID: UUID, readings: Decimal) async throws {
        errorMessage = nil

        let inspection = Inspection(
            id: UUID(),
            meterID: meterID,
            readings: readings,
            inspectionDate: .now,
            videoFilePath: nil,
            status: .draft
        )

        try await repository.add(inspection)

        inspections = try await repository.fetchAll()
    }
}
