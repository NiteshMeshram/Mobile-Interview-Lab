//
import Foundation
struct ExampleAPIClient: APIClientProtocol {
    func sendRequest(_ request: URLRequest) async throws -> APIResponse {
        print("🌐 API REQUEST")
        print("➡️ Method:", request.httpMethod ?? "UNKNOWN")
        print("➡️ URL:", request.url?.absoluteString ?? "UNKNOWN")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("⬅️ Status Code:", httpResponse.statusCode)

        if (200...299).contains(httpResponse.statusCode) {
            print("✅ API SUCCESS")
        } else {
            print("❌ API FAILURE")
        }

        return APIResponse(
            data: data,
            statusCode: httpResponse.statusCode
        )
    }
}

