import Foundation
import Testing
@testable import MeterInspect

@MainActor
struct MeterSelectionViewModelTests {

    // MARK: - Test Helpers

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

    private func makeSUT(
        repository: MockMeterRepository? = nil
    ) -> MeterSelectionViewModel {
        let repository = repository ?? MockMeterRepository()
        return MeterSelectionViewModel(repository: repository)
    }

    // MARK: - Load Meters

    @Test
    func loadMeters_loadsMetersForSelectedCustomer() async {
        let customerID = UUID()
        let meter = makeMeter(customerID: customerID)

        let repository = MockMeterRepository()
        repository.seed([meter])

        let sut = makeSUT(repository: repository)

        await sut.loadMeters(for: customerID)

        #expect(sut.meters.count == 1)
        #expect(sut.meters.first?.id == meter.id)
        #expect(sut.meters.first?.customerID == customerID)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func loadMeters_filtersMetersByCustomerID() async {
        let firstCustomerID = UUID()
        let secondCustomerID = UUID()

        let firstMeter = makeMeter(
            customerID: firstCustomerID,
            meterNumber: "MTR-1001"
        )

        let secondMeter = makeMeter(
            customerID: secondCustomerID,
            meterNumber: "MTR-2001"
        )

        let repository = MockMeterRepository()
        repository.seed([firstMeter, secondMeter])

        let sut = makeSUT(repository: repository)

        await sut.loadMeters(for: firstCustomerID)

        #expect(sut.meters.count == 1)
        #expect(sut.meters.first?.meterNumber == "MTR-1001")
        #expect(sut.meters.allSatisfy {
            $0.customerID == firstCustomerID
        })
    }

    @Test
    func loadMeters_returnsEmptyListWhenCustomerHasNoMeters() async {
        let sut = makeSUT()

        await sut.loadMeters(for: UUID())

        #expect(sut.meters.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func loadMeters_setsErrorWhenRepositoryFails() async {
        let repository = MockMeterRepository()
        repository.shouldThrowError = true

        let sut = makeSUT(repository: repository)

        await sut.loadMeters(for: UUID())

        #expect(sut.meters.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func loadMeters_clearsPreviousErrorOnRetry() async {
        let customerID = UUID()
        let repository = MockMeterRepository()
        repository.shouldThrowError = true

        let sut = makeSUT(repository: repository)

        await sut.loadMeters(for: customerID)
        #expect(sut.errorMessage != nil)

        repository.shouldThrowError = false
        repository.seed([
            makeMeter(customerID: customerID)
        ])

        await sut.loadMeters(for: customerID)

        #expect(sut.errorMessage == nil)
        #expect(sut.meters.count == 1)
    }

    // MARK: - Meter Selection

    @Test
    func selectMeter_updatesSelectedMeter() {
        let meter = makeMeter(customerID: UUID())
        let sut = makeSUT()

        sut.selectMeter(meter)

        #expect(sut.selectedMeter?.id == meter.id)
        #expect(sut.selectedMeter?.meterNumber == meter.meterNumber)
    }

    @Test
    func clearSelection_removesSelectedMeter() {
        let meter = makeMeter(customerID: UUID())
        let sut = makeSUT()

        sut.selectMeter(meter)
        sut.clearSelection()

        #expect(sut.selectedMeter == nil)
    }

    @Test
    func selectMeter_replacesPreviouslySelectedMeter() {
        let customerID = UUID()

        let firstMeter = makeMeter(
            customerID: customerID,
            meterNumber: "MTR-1001"
        )

        let secondMeter = makeMeter(
            customerID: customerID,
            meterNumber: "MTR-1002"
        )

        let sut = makeSUT()

        sut.selectMeter(firstMeter)
        sut.selectMeter(secondMeter)

        #expect(sut.selectedMeter?.id == secondMeter.id)
        #expect(sut.selectedMeter?.meterNumber == "MTR-1002")
    }

    // MARK: - Selection Reset

    @Test
    func loadMeters_resetsPreviousSelection() async {
        let firstCustomerID = UUID()
        let secondCustomerID = UUID()

        let firstMeter = makeMeter(
            customerID: firstCustomerID,
            meterNumber: "MTR-1001"
        )

        let secondMeter = makeMeter(
            customerID: secondCustomerID,
            meterNumber: "MTR-2001"
        )

        let repository = MockMeterRepository()
        repository.seed([firstMeter, secondMeter])

        let sut = makeSUT(repository: repository)

        await sut.loadMeters(for: firstCustomerID)
        sut.selectMeter(firstMeter)

        await sut.loadMeters(for: secondCustomerID)

        #expect(sut.selectedMeter == nil)
        #expect(sut.meters.count == 1)
        #expect(sut.meters.first?.id == secondMeter.id)
    }
}

