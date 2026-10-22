//
import Foundation
protocol APIClientProtocol {
    func sendRequest(_ request: URLRequest) async throws -> Data
}

