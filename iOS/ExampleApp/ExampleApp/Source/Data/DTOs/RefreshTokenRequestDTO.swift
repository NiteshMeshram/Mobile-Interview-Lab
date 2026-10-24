//
import Foundation
struct RefreshTokenRequestDTO: Encodable {

    // MARK: - Properties
    let refreshToken: String
    let expiresInMins: Int
}

