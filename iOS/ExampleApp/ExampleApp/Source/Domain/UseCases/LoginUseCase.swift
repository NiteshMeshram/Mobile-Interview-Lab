//
import Foundation
struct LoginUseCase {

    // MARK: - Properties
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // MARK: - Lifecycle
    // MARK: - Actions
    // MARK: - Private Methods

    func execute(
        username: String,
        password: String
    ) async throws -> AuthToken {

        try await authRepository.login(
            username: username,
            password: password
        )
    }
}

