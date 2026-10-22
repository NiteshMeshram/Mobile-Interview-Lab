import SwiftUI

struct AuthenticatedView: View {

    @EnvironmentObject private var sessionManager: SessionManagerImpl


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
    }
}

#Preview {
    AuthenticatedView()
}
