import Testing
@testable import MeterInspect

struct InspectionStatusTests {

    // MARK: - Valid Transitions

    @Test(arguments: [
        (InspectionStatus.draft, InspectionStatus.completed),
    ])
    func canTransition_returnsTrueForValidTransitions(
        from currentStatus: InspectionStatus,
        to newStatus: InspectionStatus
    ) {
        #expect(currentStatus.canTransition(to: newStatus))
    }

    // MARK: - Invalid Transitions

    @Test(arguments: [
        (InspectionStatus.draft, InspectionStatus.draft)
    ])
    func canTransition_returnsFalseForInvalidTransitions(
        from currentStatus: InspectionStatus,
        to newStatus: InspectionStatus
    ) {
        #expect(!currentStatus.canTransition(to: newStatus))
    }

    // MARK: - Same State Transitions

    @Test(arguments: [
        InspectionStatus.draft,
        .completed,
    ])
    func canTransition_returnsFalseForSameStatus(
        status: InspectionStatus
    ) {
        #expect(!status.canTransition(to: status))
    }
}

