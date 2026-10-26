//
import Foundation
struct MockAPIClient: APIClientProtocol {
    var responseData: Data?
    var statusCode: Int = 200

    func sendRequest(
        _ request: URLRequest
    ) async throws -> APIResponse {

        guard let responseData else {
            throw URLError(.badServerResponse)
        }

        return APIResponse(
            data: responseData,
            statusCode: statusCode
        )
    }
}

