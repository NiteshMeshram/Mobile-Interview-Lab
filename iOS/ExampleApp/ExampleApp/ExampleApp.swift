import SwiftUI
import ExampleSPM

@main
struct ExampleApp: App {

    @StateObject private var sessionManager: SessionManagerImpl
    private let authenticatedAPIClient: AuthenticatedAPIClient

    init() {
        let tokenStorage = KeychainTokenStorage()
        let tokenValidator = JWTTokenValidator()
        let apiClient = ExampleAPIClient()

        let authRepository = AuthRepositoryImpl(
            apiClient: apiClient,
            requestBuilder: RequestBuilder()
        )

        let tokenRefreshCoordinator = TokenRefreshCoordinator(
            authRepository: authRepository
        )

        let client = AuthenticatedAPIClient(
            apiClient: apiClient,
            tokenStorage: tokenStorage,
            tokenValidator: tokenValidator,
            tokenRefreshCoordinator: tokenRefreshCoordinator
        )

        self.authenticatedAPIClient = client

        _sessionManager = StateObject(
            wrappedValue: SessionManagerImpl(
                tokenStorage: tokenStorage,
                tokenValidator: tokenValidator,
                tokenRefreshCoordinator: tokenRefreshCoordinator
            )
        )
    }

    var body: some Scene {
        WindowGroup {
//            HelloView()
            Group {
                switch sessionManager.authenticationState {
                case .authenticated:
                    AuthenticatedView(authenticatedAPIClient: authenticatedAPIClient)
                case .unauthenticated:
                    LoginView(sessionManager: sessionManager)
                case .checking:
                    ProgressView("Checking session...")
                }

            }
            .environmentObject(sessionManager)
            .task {
                sessionManager.restoreSession()
            }
        }
    }
}
