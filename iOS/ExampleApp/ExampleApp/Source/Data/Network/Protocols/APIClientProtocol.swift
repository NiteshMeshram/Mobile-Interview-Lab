//
import Foundation

struct APIResponse {
    let data: Data
    let statusCode: Int
}


protocol APIClientProtocol {
    func sendRequest(_ request: URLRequest) async throws -> APIResponse
}

