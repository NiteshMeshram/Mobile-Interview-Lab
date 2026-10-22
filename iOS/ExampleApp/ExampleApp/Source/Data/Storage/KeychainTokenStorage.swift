import Foundation
import Security

final class KeychainTokenStorage: TokenStorage {

    private let service = "com.example.ExampleApp"
    private let account = "authToken"

    func saveToken(_ token: AuthToken) throws {

        let data = try JSONEncoder().encode(
            StoredAuthToken(
                accessToken: token.accessToken,
                refreshToken: token.refreshToken
            )
        )

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func getToken() throws -> AuthToken? {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess,
              let data = result as? Data else {
            throw KeychainError.readFailed(status)
        }

        let storedToken = try JSONDecoder().decode(
            StoredAuthToken.self,
            from: data
        )

        return AuthToken(
            accessToken: storedToken.accessToken,
            refreshToken: storedToken.refreshToken
        )
    }

    func deleteToken() throws {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(
            query as CFDictionary
        )

        guard status == errSecSuccess ||
                status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

private struct StoredAuthToken: Codable {

    let accessToken: String
    let refreshToken: String
}

enum KeychainError: Error {

    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)
}
