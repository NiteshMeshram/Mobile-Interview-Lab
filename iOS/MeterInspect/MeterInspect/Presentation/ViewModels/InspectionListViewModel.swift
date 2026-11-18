import Foundation
import Combine

@MainActor
final class InspectionListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var inspections: [Inspection] = []
    @Published private(set) var customersByID: [UUID: Customer] = [:]
    @Published private(set) var metersByID: [UUID: Meter] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let repository: InspectionRepository
    private let customerRepository: CustomerRepository
    private let meterRepository: MeterRepository

    // MARK: - Initialization

    init(repository: InspectionRepository,
         customerRepository: CustomerRepository,
         meterRepository: MeterRepository) {
        self.repository = repository
        self.customerRepository = customerRepository
        self.meterRepository = meterRepository
    }

    // MARK: - Actions

    func loadInspections() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let customers = try await customerRepository.fetchAll()
            let meters = try await meterRepository.fetchAll()


            customersByID = Dictionary(
                uniqueKeysWithValues: customers.map { ($0.id, $0) }
            )

            metersByID = Dictionary(
                uniqueKeysWithValues: meters.map { ($0.id, $0) }
            )
            inspections = try await repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func customer(for inspection: Inspection) -> Customer? {
        guard let meter = metersByID[inspection.meterID] else {
            return nil
        }

        return customersByID[meter.customerID]
    }

    func meter(for inspection: Inspection) -> Meter? {
        metersByID[inspection.meterID]
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
