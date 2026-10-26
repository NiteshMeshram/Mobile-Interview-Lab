//
import Foundation

actor TokenRefreshCoordinator {

    // MARK: - Properties
    private var refreshTask: Task<AuthToken, Error>?

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
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

        do {
            let token = try await task.value
            refreshTask = nil
            return token
        } catch {
            refreshTask = nil
            throw error
        }
    }
}
