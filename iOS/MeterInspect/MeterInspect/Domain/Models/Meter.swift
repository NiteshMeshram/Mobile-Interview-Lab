import Foundation

struct Meter: Identifiable, Codable, Sendable {
    let id: UUID
    let meterNumber: String
    let customerID: UUID
    let meterType: String
}

