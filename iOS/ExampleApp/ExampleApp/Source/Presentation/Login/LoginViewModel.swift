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
    private let authenticatedAPIClient: AuthenticatedAPIClient
    private let requestBuilder: RequestBuilder

    // MARK: - Lifecycle
    // MARK: - Actions
    // MARK: - Methods

    // Designated initializer
    init(loginUseCase: LoginUseCase, tokenStorage: TokenStorage, sessionManager: SessionManagerImpl,
         authenticatedAPIClient: AuthenticatedAPIClient,
         requestBuilder: RequestBuilder
    ) {
        self.loginUseCase = loginUseCase
        self.tokenStorage = tokenStorage
        self.sessionManager = sessionManager
        self.authenticatedAPIClient = authenticatedAPIClient
        self.requestBuilder = requestBuilder
    }

    // Convenience initializer
    // Convenience initializer
    convenience init(sessionManager: SessionManagerImpl) {
        let apiClient = ExampleAPIClient()
        let requestBuilder = RequestBuilder()

        let repository = AuthRepositoryImpl(
            apiClient: apiClient,
            requestBuilder: requestBuilder
        )

        let useCase = LoginUseCase(
            authRepository: repository
        )

        let tokenStorage = KeychainTokenStorage()
        let tokenValidator = JWTTokenValidator()

        let tokenRefreshCoordinator = TokenRefreshCoordinator(
            authRepository: repository
        )

        let authenticatedAPIClient = AuthenticatedAPIClient(
            apiClient: apiClient,
            tokenStorage: tokenStorage,
            tokenValidator: tokenValidator,
            tokenRefreshCoordinator: tokenRefreshCoordinator
        )

        self.init(
            loginUseCase: useCase,
            tokenStorage: tokenStorage,
            sessionManager: sessionManager,
            authenticatedAPIClient: authenticatedAPIClient,
            requestBuilder: requestBuilder
        )
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

    func fetchCurrentUser() {
        Task {
            do {
                let request = try requestBuilder.buildRequest(
                    endpoint: .currentuser
                )

                let response = try await authenticatedAPIClient.sendRequest(
                    request
                )

                print("Current user status:", response.statusCode)
                print("Current user response:", String(
                    decoding: response.data,
                    as: UTF8.self
                ))
            } catch {
                print("Current user request failed:", error)
            }
        }
    }
}

