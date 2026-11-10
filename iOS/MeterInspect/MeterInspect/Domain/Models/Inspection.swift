import Foundation

struct Inspection: Identifiable {
    let id: UUID
    let meterID: UUID
    var readings: Decimal
    let inspectionDate: Date
    var videoFilePath: String?
    var status: InspectionStatus

    /*
        Why mutating?
        Inspection is a struct (value type). The method modifies its status property, so Swift requires the mutating keyword.
    */

    mutating func transition(to newStatus: InspectionStatus) throws {
        guard status.canTransition(to: newStatus) else {
            throw InspectionError.invalidStatusTransition(
                from: status,
                to: newStatus
            )
        }

        status = newStatus
    }
}
