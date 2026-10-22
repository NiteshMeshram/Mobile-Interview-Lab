//
import Foundation
protocol TokenStorage {
   func getToken() throws -> AuthToken?
    func saveToken(_ token: AuthToken) throws
    func deleteToken() throws

}

