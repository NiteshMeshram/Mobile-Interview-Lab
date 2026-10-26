import Foundation
internal import Combine

@MainActor
final class SessionManagerImpl: SessionManager, ObservableObject {

    @Published private(set) var authenticationState: AuthenticationState = .checking

    private let tokenStorage: TokenStorage
    private let tokenValidator: TokenValidator
    private let tokenRefreshCoordinator: TokenRefreshCoordinator
    private var sessionGeneration = 0

    init(
        tokenStorage: TokenStorage,
        tokenValidator: TokenValidator,
        tokenRefreshCoordinator: TokenRefreshCoordinator
    ) {
        self.tokenStorage = tokenStorage
        self.tokenValidator = tokenValidator
        self.tokenRefreshCoordinator = tokenRefreshCoordinator
    }

    func restoreSession() {
        do {
            guard let token = try tokenStorage.getToken() else {
                authenticationState = .unauthenticated
                return
            }

            if tokenValidator.isValid(token.accessToken) {
                authenticationState = .authenticated
            } else {
                refreshSession(with: token)
            }

        } catch {
            authenticationState = .unauthenticated
        }
    }

    func login(with token: AuthToken) throws {
        try tokenStorage.saveToken(token)
        authenticationState = .authenticated
    }

    func logout() throws {
        sessionGeneration += 1
        try tokenStorage.deleteToken()
        authenticationState = .unauthenticated
    }

    private func refreshSession(with token: AuthToken) {
        let generation = sessionGeneration

        print("SESSION: Access token expired. Starting refresh...")

        Task {
            do {
                let newToken = try await tokenRefreshCoordinator.refresh(
                    using: token.refreshToken
                )

                // Ignore results from an outdated session.
                guard generation == sessionGeneration else {
                    print("SESSION: Ignoring stale refresh result")
                    return
                }

                guard tokenValidator.isValid(newToken.accessToken) else {
                    print("SESSION: Refreshed access token is invalid")
                    authenticationState = .unauthenticated
                    return
                }

                try tokenStorage.saveToken(newToken)
                authenticationState = .authenticated

                print("SESSION: Refreshed token saved successfully")
            } catch {
                guard generation == sessionGeneration else {
                    print("SESSION: Ignoring stale refresh error")
                    return
                }

                print("SESSION: Token refresh failed: \(error)")
                authenticationState = .unauthenticated
            }
        }
    }
}
