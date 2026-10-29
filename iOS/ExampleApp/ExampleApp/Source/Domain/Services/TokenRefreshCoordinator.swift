//
import Foundation

actor TokenRefreshCoordinator {

    // MARK: - Properties
    private struct InFlightRefresh {
        let id: UUID
        let task: Task<AuthToken, Error>
    }

    private var inFlightRefresh: InFlightRefresh?
    private var waitingCallerCount = 0

    private var waitingCallersContinuation:
    CheckedContinuation<Void, Never>?

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func refresh(using refreshToken: String) async throws -> AuthToken {
        if let inFlight = inFlightRefresh {
            waitingCallerCount += 1

            if waitingCallerCount == 2 {
                waitingCallersContinuation?.resume()
                waitingCallersContinuation = nil
            }

            print("🔄 TOKEN REFRESH: Waiting for existing refresh...")

            defer {
                waitingCallerCount -= 1
            }

            return try await inFlight.task.value
        }

        print("🔄 TOKEN REFRESH: Starting refresh...")

        let id = UUID()
        let task = Task {
            try await authRepository.refreshToken(
                refreshToken: refreshToken
            )
        }

        inFlightRefresh = InFlightRefresh(id: id, task: task)

        do {
            let token = try await task.value

            if inFlightRefresh?.id == id {
                inFlightRefresh = nil
            }

            return token
        } catch {
            if inFlightRefresh?.id == id {
                inFlightRefresh = nil
            }

            throw error
        }
    }

    func waitForWaitingCallers(_ count: Int) async {
        guard waitingCallerCount < count else {
            return
        }

        await withCheckedContinuation { continuation in
            waitingCallersContinuation = continuation
        }
    }
}
