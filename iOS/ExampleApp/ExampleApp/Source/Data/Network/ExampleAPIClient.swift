//
import Foundation
struct ExampleAPIClient: APIClientProtocol {
    func sendRequest(_ request: URLRequest) async throws -> Data {
        print("🌐 API REQUEST")
        print("➡️ Method:", request.httpMethod ?? "UNKNOWN")
        print("➡️ URL:", request.url?.absoluteString ?? "UNKNOWN")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("⬅️ Status Code:", httpResponse.statusCode)

            if (200...299).contains(httpResponse.statusCode) {
                print("✅ API SUCCESS")
            } else {
                print("❌ API FAILURE")
            }
        }
        
        return data
    }
}

