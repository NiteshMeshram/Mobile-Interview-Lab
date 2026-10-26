import Foundation
internal import Combine

@MainActor
final class SessionManagerImpl: SessionManager, ObservableObject {

    @Published private(set) var authenticationState: AuthenticationState = .checking

    private let tokenStorage: TokenStorage
    private let tokenValidator: TokenValidator
    private let authRepository: AuthRepository
    private let tokenRefreshCoordinator: TokenRefreshCoordinator

    init(
        tokenStorage: TokenStorage,
        tokenValidator: TokenValidator,
        authRepository: AuthRepository,
        tokenRefreshCoordinator: TokenRefreshCoordinator
    ) {
        self.tokenStorage = tokenStorage
        self.tokenValidator = tokenValidator
        self.authRepository = authRepository
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
        try tokenStorage.deleteToken()
        authenticationState = .unauthenticated
    }

    private func refreshSession(with token: AuthToken) {
        print("SESSION: Access token expired. Starting refresh...")
        Task {
            do {
                let newToken = try await authRepository.refreshToken(
                    refreshToken: token.refreshToken
                )

                try tokenStorage.saveToken(newToken)

                authenticationState = .authenticated

            } catch {
                try? tokenStorage.deleteToken()
                authenticationState = .unauthenticated
            }
        }
    }
}
