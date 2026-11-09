import Foundation

struct Customer: Identifiable, Codable, Sendable {
    let id: UUID
    let name: String
    let email: String
    let address: String
}

