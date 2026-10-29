import SwiftUI

struct AuthenticatedView: View {

    @EnvironmentObject private var sessionManager: SessionManagerImpl
    let authenticatedAPIClient: AuthenticatedAPIClient


    var body: some View {
        VStack(spacing: 16) {
            Text("Authenticated")
                .font(.largeTitle)

            Text("You are logged in.")

            Button("Logout") {
                do {
                    try sessionManager.logout()
                } catch {
                    print("Logout failed:", error)
                }
            }
        }
        .task {
            do {
                let request = try RequestBuilder().buildRequest(
                    endpoint: .currentuser
                )

                let response = try await authenticatedAPIClient.sendRequest(request)

                print("Current user status:", response.statusCode)
                print(
                    "Current user response:",
                    String(decoding: response.data, as: UTF8.self)
                )
            } catch {
                print("Current user request failed:", error)
            }
        }
    }

    private func fetchCurrentUser() async {
        do {
            let request = try RequestBuilder().buildRequest(
                endpoint: .currentuser
            )

            let response = try await authenticatedAPIClient.sendRequest(request)

            print("Current user status:", response.statusCode)
            print(
                "Current user response:",
                String(decoding: response.data, as: UTF8.self)
            )
        } catch {
            print("Current user request failed:", error)
        }
    }
}

//#Preview {
//    AuthenticatedView()
//}
