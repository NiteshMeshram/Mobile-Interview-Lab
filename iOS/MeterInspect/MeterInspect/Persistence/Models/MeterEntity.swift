import Foundation
import SwiftData

@Model
final class MeterEntity {
    @Attribute(.unique) var id: UUID
    var meterNumber: String
    var customerID: UUID
    var meterType: String

    init(
        id: UUID,
        meterNumber: String,
        customerID: UUID,
        meterType: String
    ) {
        self.id = id
        self.meterNumber = meterNumber
        self.customerID = customerID
        self.meterType = meterType
    }
}
