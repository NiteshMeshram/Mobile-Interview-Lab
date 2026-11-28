
import Foundation
import Testing
@testable import MeterInspect

@MainActor
struct InspectionListViewModelTests {

    // MARK: - Test Helpers

    private func makeCustomer(
        id: UUID = UUID(),
        name: String = "Rahul Sharma"
    ) -> Customer {
        Customer(
            id: id,
            name: name,
            email: "rahul@example.com",
            address: "Nerul, Navi Mumbai"
        )
    }

    private func makeMeter(
        id: UUID = UUID(),
        customerID: UUID,
        meterNumber: String = "MTR-1001"
    ) -> Meter {
        Meter(
            id: id,
            meterNumber: meterNumber,
            customerID: customerID,
            meterType: "Single Phase"
        )
    }

    private func makeInspection(
        id: UUID = UUID(),
        meterID: UUID,
        readings: Decimal = Decimal(string: "1450.75")!,
        status: InspectionStatus = .draft
    ) -> Inspection {
        Inspection(
            id: id,
            meterID: meterID,
            readings: readings,
            inspectionDate: .now,
            videoFilePath: nil,
            status: status
        )
    }

    private func makeSUT(
        inspectionRepository: MockInspectionRepository? = nil,
        customerRepository: MockCustomerRepository? = nil,
        meterRepository: MockMeterRepository? = nil,
        videoStorageService: MockVideoStorageService? = nil
    ) -> InspectionListViewModel {

        let inspectionRepository = inspectionRepository ?? MockInspectionRepository()
        let customerRepository = customerRepository ?? MockCustomerRepository()
        let meterRepository = meterRepository ?? MockMeterRepository()
        let videoStorageService = videoStorageService ?? MockVideoStorageService()

        return InspectionListViewModel(
            repository: inspectionRepository,
            customerRepository: customerRepository,
            meterRepository: meterRepository,
            videoStorageService: videoStorageService
        )
    }

    // MARK: - Load Inspections

    @Test
    func loadInspections_loadsDataAndResolvesRelationships() async {
        let customerID = UUID()
        let meterID = UUID()

        let customer = makeCustomer(id: customerID)
        let meter = makeMeter(id: meterID, customerID: customerID)
        let inspection = makeInspection(meterID: meterID)

        let inspectionRepository = MockInspectionRepository()
        let customerRepository = MockCustomerRepository()
        let meterRepository = MockMeterRepository()

        inspectionRepository.seed([inspection])
        customerRepository.seed([customer])
        meterRepository.seed([meter])

        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            customerRepository: customerRepository,
            meterRepository: meterRepository
        )

        await sut.loadInspections()

        #expect(sut.inspections.count == 1)
        #expect(sut.inspections.first?.id == inspection.id)

        #expect(sut.customersByID[customerID]?.name == "Rahul Sharma")
        #expect(sut.metersByID[meterID]?.meterNumber == "MTR-1001")

        #expect(sut.customer(for: inspection)?.id == customerID)
        #expect(sut.meter(for: inspection)?.id == meterID)

        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func loadInspections_returnsEmptyListWhenNoInspectionsExist() async {
        let sut = makeSUT()

        await sut.loadInspections()

        #expect(sut.inspections.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func loadInspections_setsErrorWhenInspectionRepositoryFails() async {
        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.shouldThrowError = true

        let sut = makeSUT(
            inspectionRepository: inspectionRepository
        )

        await sut.loadInspections()

        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func loadInspections_handlesMissingCustomerOrMeter() async {
        let unknownMeterID = UUID()
        let inspection = makeInspection(meterID: unknownMeterID)

        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.seed([inspection])

        let sut = makeSUT(
            inspectionRepository: inspectionRepository
        )

        await sut.loadInspections()

        #expect(sut.inspections.count == 1)
        #expect(sut.meter(for: inspection) == nil)
        #expect(sut.customer(for: inspection) == nil)
    }

    // MARK: - Create Inspection

    @Test
    func createInspection_createsAndSavesInspection() async throws {
        let meterID = UUID()
        let inspectionRepository = MockInspectionRepository()

        let sut = makeSUT(
            inspectionRepository: inspectionRepository
        )

        try await sut.createInspection(
            meterID: meterID,
            readings: Decimal(string: "1450.75")!
        )

        #expect(inspectionRepository.inspections.count == 1)

        let savedInspection = try #require(
            inspectionRepository.inspections.first
        )

        #expect(savedInspection.meterID == meterID)
        #expect(savedInspection.readings == Decimal(string: "1450.75")!)
        #expect(savedInspection.status == .draft)
        #expect(savedInspection.videoFilePath == nil)

        #expect(sut.inspections.count == 1)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func createInspection_setsErrorWhenRepositoryFails() async {
        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.shouldThrowError = true

        let sut = makeSUT(
            inspectionRepository: inspectionRepository
        )

        do {
            try await sut.createInspection(
                meterID: UUID(),
                readings: Decimal(string: "1200.50")!
            )
            Issue.record("Expected inspection creation to fail.")
        } catch {
            #expect(inspectionRepository.inspections.isEmpty)
        }
    }

    @Test
    func createInspection_doesNotSaveInspectionWhenRepositoryFails() async {
        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.shouldThrowError = true

        let sut = makeSUT(
            inspectionRepository: inspectionRepository
        )

        do {
            try await sut.createInspection(
                meterID: UUID(),
                readings: Decimal(string: "1200.50")!
            )
        } catch {
            #expect(inspectionRepository.inspections.isEmpty)
            #expect(sut.inspections.isEmpty)
        }
    }

    // MARK: - Attach Video

    @Test
    func attachVideo_savesVideoAndUpdatesInspection() async throws {
        let meterID = UUID()
        let inspection = makeInspection(meterID: meterID)

        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.seed([inspection])

        let videoStorageService = MockVideoStorageService()
        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            videoStorageService: videoStorageService
        )

        let sourceURL = URL(fileURLWithPath: "/tmp/source.mov")

        try await sut.attachVideo(
            inspectionID: inspection.id,
            sourceURL: sourceURL
        )

        let updatedInspection = try #require(
            inspectionRepository.inspections.first
        )

        #expect(updatedInspection.videoFilePath == videoStorageService.savedVideoPath)
        #expect(updatedInspection.videoSyncStatus == .pending)
        #expect(sut.inspections.count == 1)
        #expect(sut.inspections.first?.videoFilePath == videoStorageService.savedVideoPath)
    }

    @Test
    func attachVideo_throwsWhenInspectionNotFound() async {
        let inspectionRepository = MockInspectionRepository()
        let videoStorageService = MockVideoStorageService()

        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            videoStorageService: videoStorageService
        )

        let inspectionID = UUID()
        let sourceURL = URL(fileURLWithPath: "/tmp/source.mov")

        do {
            try await sut.attachVideo(
                inspectionID: inspectionID,
                sourceURL: sourceURL
            )
            Issue.record("Expected inspectionNotFound error.")
        } catch let error as InspectionError {
            switch error {
            case .inspectionNotFound:
                break
            case .invalidStatusTransition:
                Issue.record("Received an unexpected invalidStatusTransition error.")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(videoStorageService.saveVideoCallCount == 0)
    }

    @Test
    func attachVideo_throwsWhenVideoStorageFails() async {
        let meterID = UUID()
        let inspection = makeInspection(meterID: meterID)

        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.seed([inspection])

        let videoStorageService = MockVideoStorageService()
        videoStorageService.shouldThrowOnSave = true

        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            videoStorageService: videoStorageService
        )

        let sourceURL = URL(fileURLWithPath: "/tmp/source.mov")

        do {
            try await sut.attachVideo(
                inspectionID: inspection.id,
                sourceURL: sourceURL
            )
            Issue.record("Expected video storage to fail.")
        } catch {
            #expect(videoStorageService.saveVideoCallCount == 1)
        }

        let savedInspection = inspectionRepository.inspections.first
        #expect(savedInspection?.videoFilePath == nil)
        #expect(savedInspection?.videoSyncStatus == .notRequired)
    }

    @Test
    func attachVideo_deletesSavedVideoWhenRepositoryUpdateFails() async {
        let meterID = UUID()
        let inspection = makeInspection(meterID: meterID)

        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.seed([inspection])
        inspectionRepository.shouldThrowOnUpdate = true

        let videoStorageService = MockVideoStorageService()

        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            videoStorageService: videoStorageService
        )

        do {
            try await sut.attachVideo(
                inspectionID: inspection.id,
                sourceURL: URL(fileURLWithPath: "/tmp/source.mov")
            )
            Issue.record("Expected repository update to fail.")
        } catch {
            #expect(videoStorageService.saveVideoCallCount == 1)
            #expect(videoStorageService.deleteVideoCallCount == 1)
            #expect(videoStorageService.deletedPaths == [
                videoStorageService.savedVideoPath
            ])
        }
    }

    @Test
    func attachVideo_keepsSavedVideoWhenRefreshFails() async {
        let meterID = UUID()
        let inspection = makeInspection(meterID: meterID)

        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.seed([inspection])

        let videoStorageService = MockVideoStorageService()

        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            videoStorageService: videoStorageService
        )

        // Configure the repository to fail only on the final fetchAll().
        inspectionRepository.shouldThrowOnFetchAll = true

        do {
            try await sut.attachVideo(
                inspectionID: inspection.id,
                sourceURL: URL(fileURLWithPath: "/tmp/source.mov")
            )
            Issue.record("Expected inspection refresh to fail.")
        } catch {
            #expect(videoStorageService.saveVideoCallCount == 1)
            #expect(videoStorageService.deleteVideoCallCount == 0)

            let savedInspection = inspectionRepository.inspections.first
            #expect(savedInspection?.videoFilePath == videoStorageService.savedVideoPath)
            #expect(savedInspection?.videoSyncStatus == .pending)
        }
    }

    // MARK: - Replace Video

    @Test
    func replaceVideo_savesNewVideoAndDeletesOldVideo() async throws {
        // Arrange
        let meterID = UUID()
        let oldVideoPath = "MeterVideos/old-video.mov"

        var inspection = makeInspection(meterID: meterID)
        inspection.videoFilePath = oldVideoPath

        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.seed([inspection])

        let videoStorageService = MockVideoStorageService()

        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            videoStorageService: videoStorageService
        )

        let sourceURL = URL(fileURLWithPath: "/tmp/replacement.mov")

        // Act
        let newVideoPath = try await sut.replaceVideo(
            inspectionID: inspection.id,
            sourceURL: sourceURL
        )

        // Assert
        let updatedInspection = try #require(
            inspectionRepository.inspections.first
        )

        #expect(newVideoPath == videoStorageService.savedVideoPath)

        #expect(
            updatedInspection.videoFilePath == videoStorageService.savedVideoPath
        )
        #expect(updatedInspection.videoSyncStatus == .pending)

        #expect(videoStorageService.saveVideoCallCount == 1)
        #expect(videoStorageService.deleteVideoCallCount == 1)
        #expect(videoStorageService.deletedPaths == [oldVideoPath])

        #expect(sut.inspections.count == 1)
        #expect(sut.inspections.first?.videoFilePath == newVideoPath)
    }

    @Test
    func replaceVideo_deletesNewVideoWhenRepositoryUpdateFails() async {
        // Arrange
        let meterID = UUID()
        let oldVideoPath = "MeterVideos/old-video.mov"

        var inspection = makeInspection(meterID: meterID)
        inspection.videoFilePath = oldVideoPath

        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.seed([inspection])
        inspectionRepository.shouldThrowOnUpdate = true

        let videoStorageService = MockVideoStorageService()

        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            videoStorageService: videoStorageService
        )

        let sourceURL = URL(fileURLWithPath: "/tmp/replacement.mov")

        // Act & Assert
        do {
            _ = try await sut.replaceVideo(
                inspectionID: inspection.id,
                sourceURL: sourceURL
            )

            Issue.record("Expected repository update to fail.")
        } catch {
            #expect(videoStorageService.saveVideoCallCount == 1)
            #expect(videoStorageService.deleteVideoCallCount == 1)

            #expect(
                videoStorageService.deletedPaths == [
                    videoStorageService.savedVideoPath
                ]
            )

            let savedInspection = inspectionRepository.inspections.first

            #expect(savedInspection?.videoFilePath == oldVideoPath)
        }
    }

    @Test
    func replaceVideo_succeedsWhenOldVideoCleanupFails() async throws {
        // Arrange
        let meterID = UUID()
        let oldVideoPath = "MeterVideos/old-video.mov"

        var inspection = makeInspection(meterID: meterID)
        inspection.videoFilePath = oldVideoPath

        let inspectionRepository = MockInspectionRepository()
        inspectionRepository.seed([inspection])

        let videoStorageService = MockVideoStorageService()
        videoStorageService.shouldThrowOnDelete = true

        let sut = makeSUT(
            inspectionRepository: inspectionRepository,
            videoStorageService: videoStorageService
        )

        let sourceURL = URL(fileURLWithPath: "/tmp/replacement.mov")

        // Act
        let newVideoPath = try await sut.replaceVideo(
            inspectionID: inspection.id,
            sourceURL: sourceURL
        )

        // Assert
        let updatedInspection = try #require(
            inspectionRepository.inspections.first
        )

        #expect(newVideoPath == videoStorageService.savedVideoPath)
        #expect(updatedInspection.videoFilePath == newVideoPath)
        #expect(updatedInspection.videoSyncStatus == .pending)

        #expect(videoStorageService.saveVideoCallCount == 1)
        #expect(videoStorageService.deleteVideoCallCount == 1)
        #expect(videoStorageService.deletedPaths.isEmpty)
    }

    @Test
    func replaceVideo_throwsWhenInspectionNotFound() async {
        // Arrange
        let videoStorageService = MockVideoStorageService()

        let sut = makeSUT(
            videoStorageService: videoStorageService
        )

        // Act & Assert
        do {
            _ = try await sut.replaceVideo(
                inspectionID: UUID(),
                sourceURL: URL(fileURLWithPath: "/tmp/replacement.mov")
            )

            Issue.record("Expected inspectionNotFound error.")
        } catch let error as InspectionError {
            switch error {
            case .inspectionNotFound:
                break
            case .invalidStatusTransition:
                Issue.record("Received unexpected invalidStatusTransition error.")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(videoStorageService.saveVideoCallCount == 0)
        #expect(videoStorageService.deleteVideoCallCount == 0)
    }
}

