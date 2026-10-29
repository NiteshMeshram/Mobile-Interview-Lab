import Testing
@testable import ExampleApp
import Foundation

struct ExampleAppTests {

    private let validator = JWTTokenValidator()

    @Test
    func validTokenWithFutureExpiryReturnsTrue() {
        let token = makeToken(expiration: Date().addingTimeInterval(3600))

        #expect(validator.isValid(token))
    }

    @Test
    func expiredTokenReturnsFalse() {
        let token = makeToken(expiration: Date().addingTimeInterval(-3600))

        #expect(!validator.isValid(token))
    }

    @Test
    func malformedTokenReturnsFalse() {
        #expect(!validator.isValid("invalid-token"))
    }

    @Test
    func expirationDateReturnsExpectedDate() {
        let expectedDate = Date(timeIntervalSince1970: 1_900_000_000)
        let token = makeToken(expiration: expectedDate)

        let actualDate = validator.expirationDate(for: token)

        #expect(actualDate == expectedDate)
    }

    private func makeToken(expiration: Date) -> String {
        let header = #"{"alg":"none","typ":"JWT"}"#
        let payload = #"{"exp":\#(expiration.timeIntervalSince1970)}"#

        return "\(base64URL(header)).\(base64URL(payload)).signature"
    }

    private func base64URL(_ value: String) -> String {
        Data(value.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

