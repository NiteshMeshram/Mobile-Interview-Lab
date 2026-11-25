import Testing
@testable import MeterInspect

struct InspectionStatusTests {

    // MARK: - Valid Transitions

    @Test(arguments: [
        (InspectionStatus.draft, InspectionStatus.completed),
        (.completed, .pendingSync),
        (.pendingSync, .syncing),
        (.syncing, .synced),
        (.syncing, .syncFailed),
        (.syncFailed, .pendingSync)
    ])
    func canTransition_returnsTrueForValidTransitions(
        from currentStatus: InspectionStatus,
        to newStatus: InspectionStatus
    ) {
        #expect(currentStatus.canTransition(to: newStatus))
    }

    // MARK: - Invalid Transitions

    @Test(arguments: [
        (InspectionStatus.draft, InspectionStatus.pendingSync),
        (.draft, .syncing),
        (.draft, .synced),
        (.completed, .draft),
        (.completed, .syncing),
        (.pendingSync, .completed),
        (.pendingSync, .synced),
        (.syncing, .pendingSync),
        (.synced, .syncing),
        (.synced, .syncFailed),
        (.syncFailed, .syncing),
        (.syncFailed, .synced)
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
        .pendingSync,
        .syncing,
        .syncFailed,
        .synced
    ])
    func canTransition_returnsFalseForSameStatus(
        status: InspectionStatus
    ) {
        #expect(!status.canTransition(to: status))
    }
}

