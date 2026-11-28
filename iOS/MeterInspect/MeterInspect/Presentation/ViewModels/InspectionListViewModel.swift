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
    let videoStorageService: VideoStorageService

    // MARK: - Dependencies

    private let repository: InspectionRepository
    private let customerRepository: CustomerRepository
    private let meterRepository: MeterRepository

    // MARK: - Initialization

    init(repository: InspectionRepository,
         customerRepository: CustomerRepository,
         meterRepository: MeterRepository,
         videoStorageService: VideoStorageService
    ) {
        self.repository = repository
        self.customerRepository = customerRepository
        self.meterRepository = meterRepository
        self.videoStorageService = videoStorageService
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

    func attachVideo(inspectionID: UUID, sourceURL: URL) async throws {

        guard var inspection = try await repository.fetch(by: inspectionID) else {
            throw InspectionError.inspectionNotFound
        }

        // 1. Save video to local storage

        let relativePath = try await videoStorageService.saveVideo(from: sourceURL, for: inspectionID)

        // 2. Update inspection metadata
        inspection.videoFilePath = relativePath
        inspection.videoSyncStatus = .pending

        // 3. Persist the updated inspection

        do {
            try await repository.update(inspection)
            let savedInspection = try await repository.fetch(by: inspectionID)
            print("ATTACH - After save:", savedInspection?.videoSyncStatus as Any)

        } catch {
            // 4. Roll back video storage if persistence fails
            try? await videoStorageService.deleteVideo(at: relativePath)
            throw error
        }

        // 5. Refresh inspections list

        inspections = try await repository.fetchAll()

        print(
            "ATTACH - After refresh:",
            inspections.first(where: { $0.id == inspectionID })?.videoSyncStatus as Any
        )
    }

    func replaceVideo(
        inspectionID: UUID,
        sourceURL: URL
    ) async throws -> String {
        guard var inspection = try await repository.fetch(by: inspectionID) else {
            throw InspectionError.inspectionNotFound
        }

        // Retain the existing video path.
        let oldVideoPath = inspection.videoFilePath

        // 1. Save replacement video locally.
        let newVideoPath = try await videoStorageService.saveVideo(
            from: sourceURL,
            for: inspectionID
        )

        // 2. Update inspection metadata.
        inspection.videoFilePath = newVideoPath
        inspection.videoSyncStatus = .pending

        // 3. Persist the updated inspection.
        do {
            try await repository.update(inspection)
        } catch {
            // Preserve the old video if persistence fails.
            try? await videoStorageService.deleteVideo(at: newVideoPath)
            throw error
        }

        // 4. Delete old video only after successful persistence.
        if let oldVideoPath {
            try? await videoStorageService.deleteVideo(at: oldVideoPath)
        }

        // 5. Refresh inspection list.
        inspections = try await repository.fetchAll()

        return newVideoPath
    }
}
