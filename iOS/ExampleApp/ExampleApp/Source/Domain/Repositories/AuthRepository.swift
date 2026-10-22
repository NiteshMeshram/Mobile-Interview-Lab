//
import Foundation
protocol AuthRepository {
    func login(username: String, password: String) async throws -> AuthToken
    func refreshToken(refreshToken: String) async throws -> AuthToken
}

