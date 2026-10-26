import Testing
@testable import ExampleApp
import Foundation

struct SessionManagerTests {

    @Test
    @MainActor
    func logoutDuringRefreshKeepsSessionUnauthenticated() async throws {
        let oldToken = AuthToken(
            accessToken: "expired-access-token",
            refreshToken: "old-refresh-token"
        )

        let refreshedToken = AuthToken(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token"
        )

        let storage = MockTokenStorage(token: oldToken)
        let validator = MockTokenValidator()
        let repository = MockAuthRepository(tokenToReturn: refreshedToken)
        let coordinator = TokenRefreshCoordinator(
            authRepository: repository
        )

        await repository.suspendNextRefresh()

        let sut = SessionManagerImpl(
            tokenStorage: storage,
            tokenValidator: validator,
            tokenRefreshCoordinator: coordinator
        )

        sut.restoreSession()

        // Wait until refresh is suspended inside the repository.
        await repository.waitForRefreshToStart()

        try sut.logout()

        #expect(sut.authenticationState == .unauthenticated)

        // Complete the refresh after logout.
        await repository.resumeRefresh()

        // Allow the MainActor refresh task to finish.
        for _ in 0..<20 {
            await Task.yield()
        }

        #expect(sut.authenticationState == .unauthenticated)
        #expect(storage.savedToken == nil)
    }
}

private final class MockTokenStorage: TokenStorage {
    var token: AuthToken?
    var savedToken: AuthToken?

    init(token: AuthToken?) {
        self.token = token
    }

    func getToken() throws -> AuthToken? {
        token
    }

    func saveToken(_ token: AuthToken) throws {
        savedToken = token
        self.token = token
    }

    func deleteToken() throws {
        token = nil
    }
}

private struct MockTokenValidator: TokenValidator {
    func isValid(_ accessToken: String) -> Bool {
        accessToken == "new-access-token"
    }

    func expirationDate(for accessToken: String) -> Date? {
        nil
    }

    func needsRefresh(
        _ accessToken: String,
        skew: TimeInterval
    ) -> Bool {
        !isValid(accessToken)
    }
}

