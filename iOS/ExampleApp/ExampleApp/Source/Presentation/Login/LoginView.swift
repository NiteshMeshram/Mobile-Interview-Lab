
import SwiftUI

struct LoginView: View {

    // MARK: - Properties
    @StateObject private var viewModel: LoginViewModel
    // MARK: - Lifecycle
    // MARK: - Actions
    // MARK: - Private Methods

    init(sessionManager: SessionManagerImpl) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(
                sessionManager: sessionManager
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Text("Login View")
                    .font(.largeTitle)
                Spacer()
            }

            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 50)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 50)

            Button("Login") {
                viewModel.login()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

//#Preview {
//    LoginView()
//}
