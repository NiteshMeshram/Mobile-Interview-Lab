//
import Foundation
struct AuthRepositoryImpl: AuthRepository {
    private let apiClient: APIClientProtocol
    private let requestBuilder: RequestBuilder

    init(
        apiClient: APIClientProtocol,
        requestBuilder: RequestBuilder
    ) {
        self.apiClient = apiClient
        self.requestBuilder = requestBuilder
    }

    func login(username: String, password: String) async throws -> AuthToken {
        let loginDTO = LoginRequestDTO(
            username: username,
            password: password,
            expiresInMins: 2
        )

        let request = try requestBuilder.buildRequest(
            endpoint: .login,
            body: loginDTO
        )

        let response = try await apiClient.sendRequest(request)
        let responseDTO = try JSONDecoder().decode(
            LoginResponseDTO.self,
            from: response.data
        )

        return responseDTO.toEntity()
    }

    func refreshToken(refreshToken: String) async throws -> AuthToken {

        let refreshDTO = RefreshTokenRequestDTO(
            refreshToken: refreshToken,
            expiresInMins: 30)
        let request = try requestBuilder.buildRequest(endpoint: .refresh, body: refreshDTO)

        let response = try await apiClient.sendRequest(request)
        let responseDTO = try JSONDecoder().decode(
            RefreshTokenResponseDTO.self,
            from: response.data
        )

        return responseDTO.toEntity()
    }
}

