//
import Foundation
struct MockAPIClient: APIClientProtocol {
    var responseData: Data?

    func sendRequest(
        _ request: URLRequest
    ) async throws -> Data {

        guard let responseData else {
            throw URLError(.badServerResponse)
        }

        return responseData
    }
}

