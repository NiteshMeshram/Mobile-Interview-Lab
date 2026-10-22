import Foundation
import Foundation

final class MockTokenStorage: TokenStorage {
    private var token: AuthToken?

    func saveToken(_ token: AuthToken) throws {
        self.token = token
    }

    func getToken() throws -> AuthToken? {
        token
    }

    func deleteToken() throws {
        token = nil
    }
}

