import Foundation

enum InspectionError: Error {
    case invalidStatusTransition(
        from: InspectionStatus,
        to: InspectionStatus
    )
}
