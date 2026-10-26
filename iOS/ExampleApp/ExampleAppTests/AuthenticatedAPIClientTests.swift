
import Testing
@testable import ExampleApp
import Foundation

struct AuthenticatedAPIClientTests {

    @Test
    func successfulRequestDoesNotRefreshToken() async throws {
        let originalToken = AuthToken(
            accessToken: "valid-access-token",
            refreshToken: "valid-refresh-token"
        )

        let storage = TestTokenStorage(token: originalToken)
        let repository = TestAuthRepository(
            tokenToReturn: AuthToken(
                accessToken: "new-access-token",
                refreshToken: "new-refresh-token"
            )
        )
        let apiClient = MockSequenceAPIClient(
            responses: [
                APIResponse(data: Data("success".utf8), statusCode: 200)
            ]
        )

        let sut = makeSUT(
            apiClient: apiClient,
            storage: storage,
            repository: repository
        )

        let request = makeRequest()
        let response = try await sut.sendRequest(request)

        #expect(response.statusCode == 200)
        #expect(await repository.refreshCallCount == 0)
        #expect(apiClient.recordedRequests.count == 1)
        #expect(
            apiClient.recordedRequests[0].value(
                forHTTPHeaderField: "Authorization"
            ) == "Bearer valid-access-token"
        )
    }

    @Test
    func unauthorizedRequestRefreshesTokenAndRetriesOnce() async throws {
        let originalToken = AuthToken(
            accessToken: "expired-access-token",
            refreshToken: "valid-refresh-token"
        )
        let refreshedToken = AuthToken(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token"
        )

        let storage = TestTokenStorage(token: originalToken)
        let repository = TestAuthRepository(
            tokenToReturn: refreshedToken
        )
        let apiClient = MockSequenceAPIClient(
            responses: [
                APIResponse(data: Data(), statusCode: 401),
                APIResponse(data: Data("success".utf8), statusCode: 200)
            ]
        )

        let sut = makeSUT(
            apiClient: apiClient,
            storage: storage,
            repository: repository
        )

        let response = try await sut.sendRequest(makeRequest())

        #expect(response.statusCode == 200)
        #expect(await repository.refreshCallCount == 1)
        #expect(apiClient.recordedRequests.count == 2)

        #expect(
            apiClient.recordedRequests[0].value(
                forHTTPHeaderField: "Authorization"
            ) == "Bearer expired-access-token"
        )

        #expect(
            apiClient.recordedRequests[1].value(
                forHTTPHeaderField: "Authorization"
            ) == "Bearer new-access-token"
        )

        #expect(
            (try storage.getToken())?.accessToken == "new-access-token"
        )
    }

    @Test
    func secondUnauthorizedResponseDoesNotRetryAgain() async throws {
        let originalToken = AuthToken(
            accessToken: "expired-access-token",
            refreshToken: "valid-refresh-token"
        )
        let refreshedToken = AuthToken(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token"
        )

        let storage = TestTokenStorage(token: originalToken)
        let repository = TestAuthRepository(
            tokenToReturn: refreshedToken
        )
        let apiClient = MockSequenceAPIClient(
            responses: [
                APIResponse(data: Data(), statusCode: 401),
                APIResponse(data: Data(), statusCode: 401)
            ]
        )

        let sut = makeSUT(
            apiClient: apiClient,
            storage: storage,
            repository: repository
        )

        let response = try await sut.sendRequest(makeRequest())

        #expect(response.statusCode == 401)
        #expect(await repository.refreshCallCount == 1)
        #expect(apiClient.recordedRequests.count == 2)
    }

    @Test
    func concurrentUnauthorizedRequestsShareRefresh() async throws {
        let originalToken = AuthToken(
            accessToken: "expired-access-token",
            refreshToken: "valid-refresh-token"
        )

        let refreshedToken = AuthToken(
            accessToken: "new-access-token",
            refreshToken: "rotated-refresh-token"
        )

        let storage = TestTokenStorage(token: originalToken)
        let repository = TestAuthRepository(
            tokenToReturn: refreshedToken
        )

        let apiClient = MockSequenceAPIClient(
            responses: [
                APIResponse(data: Data(), statusCode: 401),
                APIResponse(data: Data(), statusCode: 401),
                APIResponse(data: Data("success".utf8), statusCode: 200),
                APIResponse(data: Data("success".utf8), statusCode: 200)
            ]
        )

        let sut = makeSUT(
            apiClient: apiClient,
            storage: storage,
            repository: repository
        )

        async let firstResponse = sut.sendRequest(makeRequest())
        async let secondResponse = sut.sendRequest(makeRequest())

        let responses = try await [firstResponse, secondResponse]

        #expect(responses.allSatisfy { $0.statusCode == 200 })
        #expect(await repository.refreshCallCount == 1)
        #expect(apiClient.recordedRequests.count == 4)
        #expect(
            (try storage.getToken())?.refreshToken == "rotated-refresh-token"
        )
    }

    private func makeSUT(
        apiClient: MockSequenceAPIClient,
        storage: TestTokenStorage,
        repository: TestAuthRepository
    ) -> AuthenticatedAPIClient {
        let coordinator = TokenRefreshCoordinator(
            authRepository: repository
        )

        return AuthenticatedAPIClient(
            apiClient: apiClient,
            tokenStorage: storage,
            tokenValidator: TestTokenValidator(),
            tokenRefreshCoordinator: coordinator
        )
    }

    private func makeRequest() -> URLRequest {
        URLRequest(
            url: URL(string: "https://example.com/profile")!
        )
    }
}

// MARK: - Test doubles

private final class TestTokenStorage: TokenStorage {
    private var token: AuthToken?

    init(token: AuthToken?) {
        self.token = token
    }

    func getToken() throws -> AuthToken? {
        token
    }

    func saveToken(_ token: AuthToken) throws {
        self.token = token
    }

    func deleteToken() throws {
        token = nil
    }
}

private struct TestTokenValidator: TokenValidator {
    func isValid(_ accessToken: String) -> Bool {
        !accessToken.isEmpty
    }

    func expirationDate(for accessToken: String) -> Date? {
        Date().addingTimeInterval(3600)
    }

    func needsRefresh(
        _ accessToken: String,
        skew: TimeInterval
    ) -> Bool {
        false
    }
}

private actor TestAuthRepository: AuthRepository {
    private let tokenToReturn: AuthToken
    private(set) var refreshCallCount = 0

    init(tokenToReturn: AuthToken) {
        self.tokenToReturn = tokenToReturn
    }

    func login(
        username: String,
        password: String
    ) async throws -> AuthToken {
        tokenToReturn
    }

    func refreshToken(
        refreshToken: String
    ) async throws -> AuthToken {
        refreshCallCount += 1
        return tokenToReturn
    }
}

private final class MockSequenceAPIClient: APIClientProtocol {
    private let responses: [APIResponse]
    private var responseIndex = 0

    private(set) var recordedRequests: [URLRequest] = []

    init(responses: [APIResponse]) {
        self.responses = responses
    }

    func sendRequest(
        _ request: URLRequest
    ) async throws -> APIResponse {
        recordedRequests.append(request)

        guard responseIndex < responses.count else {
            throw URLError(.badServerResponse)
        }

        let response = responses[responseIndex]
        responseIndex += 1

        return response
    }
}

