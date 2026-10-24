import SwiftUI
import ExampleSPM

@main
struct ExampleApp: App {

    @StateObject private var sessionManager: SessionManagerImpl

    init() {
        let tokenStorage = KeychainTokenStorage()
        let tokenValidator = JWTTokenValidator()
        let apiClient = ExampleAPIClient()

        let authRepository = AuthRepositoryImpl(
            apiClient: apiClient,
            requestBuilder: RequestBuilder()
        )

        let tokenRefreshCoordinator = TokenRefreshCoordinator(
            authRepository: authRepository,
            tokenStorage: tokenStorage,
            tokenValidator: tokenValidator
        )

        _sessionManager = StateObject(
            wrappedValue: SessionManagerImpl(
                tokenStorage: tokenStorage,
                tokenValidator: tokenValidator,
                authRepository: authRepository,
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
                    AuthenticatedView()
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
