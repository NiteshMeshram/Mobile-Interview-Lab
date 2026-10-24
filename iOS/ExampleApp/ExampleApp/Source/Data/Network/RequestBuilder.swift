//
import Foundation
struct RequestBuilder {

    // MARK: - Properties
    let baseURL = "https://dummyjson.com"
    // MARK: - Lifecycle
    // MARK: - Actions
    // MARK: - Private Methods

    func buildRequest(
        endpoint: APIEndpoint,
        body: Encodable? = nil
    ) throws -> URLRequest {

        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}

