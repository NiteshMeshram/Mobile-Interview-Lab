//
import Foundation

//@MainActor
protocol SessionManager {

    var authenticationState: AuthenticationState { get }

    func restoreSession()
    func login(with token: AuthToken) throws
    func logout() throws
}

