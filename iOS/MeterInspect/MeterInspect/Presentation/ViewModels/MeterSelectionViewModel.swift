
import Foundation
import Combine

@MainActor
final class MeterSelectionViewModel: ObservableObject {

    // MARK: - Properties

    @Published private(set) var meters: [Meter] = []
    @Published private(set) var selectedMeter: Meter?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: MeterRepository

    // MARK: - Initialization

    init(repository: MeterRepository) {
        self.repository = repository
    }

    // MARK: - Actions

    func loadMeters(for customerID: UUID) async {
        isLoading = true
        errorMessage = nil
        selectedMeter = nil
        meters = []

        defer {
            isLoading = false
        }

        do {
            meters = try await repository.fetchAll(for: customerID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectMeter(_ meter: Meter) {
        selectedMeter = meter
    }

    func clearSelection() {
        selectedMeter = nil
    }
}

