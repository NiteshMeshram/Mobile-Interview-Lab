//
import Foundation
nonisolated protocol TokenValidator {
    func isValid(_ accessToken: String) -> Bool
    func expirationDate(for accessToken: String) -> Date?
}
