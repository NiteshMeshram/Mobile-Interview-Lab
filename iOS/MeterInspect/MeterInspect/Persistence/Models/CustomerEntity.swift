import Foundation
import SwiftData

@Model
final class CustomerEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var address: String

    init(
        id: UUID,
        name: String,
        email: String,
        address: String
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.address = address
    }
}

