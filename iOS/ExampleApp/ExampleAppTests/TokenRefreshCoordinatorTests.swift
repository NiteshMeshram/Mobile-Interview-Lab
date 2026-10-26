import Testing
@testable import ExampleApp
import Foundation

struct TokenRefreshCoordinatorTests {
    @Test
    func refreshReturnsTokenFromRepository() async throws {
        let expectedToken = AuthToken(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token"
        )

        let repository = MockAuthRepository(tokenToReturn: expectedToken)
        let coordinator = TokenRefreshCoordinator(
            authRepository: repository
        )

        let actualToken = try await coordinator.refresh(
            using: "old-refresh-token"
        )

        #expect(actualToken.accessToken == expectedToken.accessToken)
        #expect(actualToken.refreshToken == expectedToken.refreshToken)
    }

    @Test
    func failedRefreshAllowsSubsequentRetry() async throws {
        let expectedToken = AuthToken(
            accessToken: "recovered-access-token",
            refreshToken: "recovered-refresh-token"
        )

        let repository = MockAuthRepository(
            tokenToReturn: expectedToken
        )
        let coordinator = TokenRefreshCoordinator(
            authRepository: repository
        )

        await repository.failNextRefresh()

        do {
            _ = try await coordinator.refresh(using: "old-refresh-token")
            Issue.record("Expected the first refresh to fail")
        } catch is MockAuthRepository.MockError {
            // Expected failure.
        }

        let recoveredToken = try await coordinator.refresh(
            using: "old-refresh-token"
        )

        #expect(recoveredToken.accessToken == expectedToken.accessToken)
        #expect(await repository.refreshCallCount == 2)
    }


    @Test
    func concurrentRefreshRequestsShareOneRefreshOperation() async throws {
        let expectedToken = AuthToken(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token"
        )

        let repository = MockAuthRepository(tokenToReturn: expectedToken)
        let coordinator = TokenRefreshCoordinator(
            authRepository: repository
        )

        await repository.suspendNextRefresh()

        let first = Task {
            try await coordinator.refresh(using: "old-refresh-token")
        }

        // Wait until the first repository refresh is suspended.
        await repository.waitForRefreshToStart()

        // These requests arrive while the first refresh is in flight.
        async let second = coordinator.refresh(using: "old-refresh-token")
        async let third = coordinator.refresh(using: "old-refresh-token")

        // Wait until both callers have joined the in-flight refresh.
        await coordinator.waitForWaitingCallers(2)

        // Release the shared refresh only after both callers have joined.
        await repository.resumeRefresh()

        let firstToken = try await first.value
        let secondToken = try await second
        let thirdToken = try await third

        #expect(firstToken.accessToken == expectedToken.accessToken)
        #expect(secondToken.accessToken == expectedToken.accessToken)
        #expect(thirdToken.accessToken == expectedToken.accessToken)
        #expect(await repository.refreshCallCount == 1)
    }

}


private actor MockAuthRepository: AuthRepository {
    private let tokenToReturn: AuthToken
    private(set) var refreshCallCount = 0
    private var shouldSuspendNextRefresh = false
    private var refreshStartedContinuation: CheckedContinuation<Void, Never>?
    private var refreshReleaseContinuation: CheckedContinuation<Void, Never>?


    init(tokenToReturn: AuthToken) {
        self.tokenToReturn = tokenToReturn
    }

    func login(username: String, password: String) async throws -> AuthToken {
        tokenToReturn
    }

    func refreshToken(refreshToken: String) async throws -> AuthToken {
        refreshCallCount += 1

        if shouldFailNextRefresh {
            shouldFailNextRefresh = false
            throw MockError.refreshFailed
        }

        if shouldSuspendNextRefresh {
            shouldSuspendNextRefresh = false

            await withCheckedContinuation { continuation in
                refreshReleaseContinuation = continuation
                refreshStartedContinuation?.resume()
                refreshStartedContinuation = nil
            }
        }

        return tokenToReturn
    }

    enum MockError: Error {
        case refreshFailed
    }

    private var shouldFailNextRefresh = false

    func failNextRefresh() {
        shouldFailNextRefresh = true
    }

    func suspendNextRefresh() {
        shouldSuspendNextRefresh = true
    }

    func waitForRefreshToStart() async {
        if refreshReleaseContinuation != nil {
            return
        }

        await withCheckedContinuation { continuation in
            refreshStartedContinuation = continuation
        }
    }

    func resumeRefresh() {
        refreshReleaseContinuation?.resume()
        refreshReleaseContinuation = nil
    }
}


