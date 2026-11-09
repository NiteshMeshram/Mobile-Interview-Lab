import Testing
import Foundation
@testable import MeterInspect

struct MeterTests {

    @Test
    func meterInitialization() {
        let meterID = UUID()
        let customerID = UUID()

        let meter = Meter(
            id: meterID,
            meterNumber: "MTR-1001",
            customerID: customerID,
            meterType: "Digital"
        )

        #expect(meter.id == meterID)
        #expect(meter.meterNumber == "MTR-1001")
        #expect(meter.customerID == customerID)
        #expect(meter.meterType == "Digital")
    }
}
