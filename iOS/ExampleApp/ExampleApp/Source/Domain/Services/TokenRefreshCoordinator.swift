//
import Foundation

actor TokenRefreshCoordinator {

    // MARK: - Properties
    private var refreshTask: Task<AuthToken, Error>?

    private let authRepository: AuthRepository
    private let tokenStorage: TokenStorage
    private let tokenValidator: TokenValidator

    init(authRepository: AuthRepository,
         tokenStorage: TokenStorage,
         tokenValidator: TokenValidator
    ) {
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
        self.tokenValidator = tokenValidator
    }

    func refresh(using refreshToken: String) async throws -> AuthToken {

        if let refreshTask {
            print("🔄 TOKEN REFRESH: Waiting for existing refresh...")
            return try await refreshTask.value
        }

        print("🔄 TOKEN REFRESH: Starting refresh...")

        let task = Task {
            try await authRepository.refreshToken(
                refreshToken: refreshToken
            )
        }

        refreshTask = task

        defer {
            refreshTask = nil
        }

        return try await task.value
    }

    func scheduleRefresh(
        for token: AuthToken,
        expirationDate: Date
    ) {
        let refreshDate = expirationDate.addingTimeInterval(-60)
        let delay = refreshDate.timeIntervalSinceNow

        print("⏰ TOKEN REFRESH: Token expires at:", expirationDate)
        print("⏰ TOKEN REFRESH: Refresh scheduled in:", delay, "seconds")

        Task {
            guard delay > 0 else {
                print("⏰ TOKEN REFRESH: Token is already within refresh window")
                return
            }

            try? await Task.sleep(
                nanoseconds: UInt64(delay * 1_000_000_000)
            )

            print("⏰ TOKEN REFRESH: Refresh time reached")

            do {
                let newToken = try await refresh(
                    using: token.refreshToken
                )

                print("✅ TOKEN REFRESH: New token received")

                try await tokenStorage.saveToken(newToken)

                print("💾 TOKEN REFRESH: New token saved")

                if let expirationDate = tokenValidator.expirationDate(
                    for: newToken.accessToken
                ) {
                    scheduleRefresh(
                        for: newToken,
                        expirationDate: expirationDate
                    )
                }

            } catch {
                print("❌ TOKEN REFRESH: Failed:", error)
            }
        }
    }
}

