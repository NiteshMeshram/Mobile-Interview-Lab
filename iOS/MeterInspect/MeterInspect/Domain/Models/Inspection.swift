import Foundation

struct Inspection {
    let id: UUID
    let meterID: UUID
    var readings: Decimal
    let inspectionDate: Date
    var videoFilePath: String?
    var status: InspectionStatus
}

