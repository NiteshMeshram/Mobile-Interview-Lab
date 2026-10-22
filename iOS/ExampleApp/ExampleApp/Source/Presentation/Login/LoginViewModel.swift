//
import Foundation
internal import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Properties
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading: Bool = false

    // MARK: - Dependencies

    private let loginUseCase: LoginUseCase
    private let tokenStorage: TokenStorage
    private let sessionManager: SessionManagerImpl

    // MARK: - Lifecycle
    // MARK: - Actions
    // MARK: - Methods

    // Designated initializer
    init(loginUseCase: LoginUseCase, tokenStorage: TokenStorage, sessionManager: SessionManagerImpl) {
        self.loginUseCase = loginUseCase
        self.tokenStorage = tokenStorage
        self.sessionManager = sessionManager
    }

    // Convenience initializer
    convenience init(sessionManager: SessionManagerImpl) {
        let apiClient = ExampleAPIClient()

        let repository = AuthRepositoryImpl(
            apiClient: apiClient,
            requestBuilder: RequestBuilder()
        )

        let useCase = LoginUseCase(
            authRepository: repository
        )

        let tokenStorage = KeychainTokenStorage()

        self.init(loginUseCase: useCase, tokenStorage: tokenStorage, sessionManager: sessionManager)
    }

    func login() {
        isLoading = true
        Task {
            do {
                let authToken = try await loginUseCase.execute(
                    username: username,
                    password: password
                )

                try sessionManager.login(with: authToken)

                print("Token saved successfully")


                print("Access Token:", authToken.accessToken)
                print("Refresh Token:", authToken.refreshToken)

            } catch {
                print("Login failed:", error)
            }
        }
    }
}

