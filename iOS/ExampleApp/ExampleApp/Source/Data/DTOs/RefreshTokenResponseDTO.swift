//
import Foundation
struct RefreshTokenResponseDTO: Decodable {

    // MARK: - Properties
    let accessToken: String
    let refreshToken: String
}

extension RefreshTokenResponseDTO {
    func toEntity() -> AuthToken {
        AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}

