
import Foundation
struct LoginResponseDTO: Decodable {

    // MARK: - Properties
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let accessToken: String
    let refreshToken: String
    // MARK: - Lifecycle
    // MARK: - Actions
    // MARK: - Private Methods
}


extension LoginResponseDTO {
    func toEntity() -> AuthToken {
        AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}
