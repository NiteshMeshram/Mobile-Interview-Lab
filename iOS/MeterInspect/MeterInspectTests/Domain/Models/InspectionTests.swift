import Testing
import Foundation
@testable import MeterInspect

struct InspectionTests {

    private func makeInspection(
        status: InspectionStatus = .draft
    ) -> Inspection {
        Inspection(
            id: UUID(),
            meterID: UUID(),
            readings: 1250.50,
            inspectionDate: Date(),
            videoFilePath: nil,
            status: status
        )
    }

    @Test
    func validStatusTransition() throws {
        var inspection = makeInspection()

        try inspection.transition(to: .completed)

        #expect(inspection.status == .completed)
    }

    @Test
    func invalidStatusTransitionThrowsError() {
        var inspection = makeInspection()

        #expect(throws: InspectionError.self) {
            try inspection.transition(to: .synced)
        }
    }

    @Test
    func failedSyncCanBeRetried() throws {
        var inspection = makeInspection(status: .syncing)

        try inspection.transition(to: .syncFailed)
        try inspection.transition(to: .pendingSync)

        #expect(inspection.status == .pendingSync)
    }

    @Test
    func syncedInspectionCannotTransitionAgain() {
        var inspection = makeInspection(status: .synced)

        #expect(throws: InspectionError.self) {
            try inspection.transition(to: .pendingSync)
        }
    }
}
