
import Foundation

struct AuthenticatedAPIClient {
    private let apiClient: APIClientProtocol
    private let tokenStorage: TokenStorage
    private let tokenValidator: TokenValidator
    private let tokenRefreshCoordinator: TokenRefreshCoordinator

    init(
        apiClient: APIClientProtocol,
        tokenStorage: TokenStorage,
        tokenValidator: TokenValidator,
        tokenRefreshCoordinator: TokenRefreshCoordinator
    ) {
        self.apiClient = apiClient
        self.tokenStorage = tokenStorage
        self.tokenValidator = tokenValidator
        self.tokenRefreshCoordinator = tokenRefreshCoordinator
    }

    func sendRequest(_ request: URLRequest) async throws -> APIResponse {
        guard let token = try tokenStorage.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }

        let response = try await apiClient.sendRequest(
            request.withBearerToken(token.accessToken)
        )

        guard response.statusCode == 401 else {
            return response
        }

        // Reuse a newer token if another request already refreshed it.
        let latestToken = try tokenStorage.getToken()

        let refreshedToken: AuthToken

        if let latestToken,
           latestToken.accessToken != token.accessToken {
            refreshedToken = latestToken
        } else {
            refreshedToken = try await tokenRefreshCoordinator.refresh(
                using: token.refreshToken
            )

            guard tokenValidator.isValid(refreshedToken.accessToken) else {
                throw URLError(.userAuthenticationRequired)
            }

            try tokenStorage.saveToken(refreshedToken)
        }

        // Retry once only. A second 401 is returned without another refresh.
        return try await apiClient.sendRequest(
            request.withBearerToken(refreshedToken.accessToken)
        )
    }
}

private extension URLRequest {
    func withBearerToken(_ accessToken: String) -> URLRequest {
        var request = self
        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }
}

