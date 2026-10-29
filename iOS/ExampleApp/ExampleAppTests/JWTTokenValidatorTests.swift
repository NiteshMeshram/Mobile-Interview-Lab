
import Testing
import Foundation
@testable import ExampleApp

struct JWTTokenValidatorTests {

    private let sut = JWTTokenValidator()
    private let skew: TimeInterval = 60

    @Test
    func tokenExpiringInTenMinutesDoesNotNeedRefresh() {
        let token = makeToken(expiringIn: 600)

        #expect(sut.needsRefresh(token, skew: skew) == false)
    }

    @Test
    func tokenExpiringInNinetySecondsDoesNotNeedRefresh() {
        let token = makeToken(expiringIn: 90)

        #expect(sut.needsRefresh(token, skew: skew) == false)
    }

    @Test
    func tokenExpiringInThirtySecondsNeedsRefresh() {
        let token = makeToken(expiringIn: 30)

        #expect(sut.needsRefresh(token, skew: skew) == true)
    }

    @Test
    func expiredTokenNeedsRefresh() {
        let token = makeToken(expiringIn: -30)

        #expect(sut.needsRefresh(token, skew: skew) == true)
    }

    @Test
    func invalidTokenNeedsRefresh() {
        #expect(sut.needsRefresh("invalid-token", skew: skew) == true)
    }

    private func makeToken(expiringIn seconds: TimeInterval) -> String {
        let header = #"{"alg":"none","typ":"JWT"}"#
        let expiration = Date().timeIntervalSince1970 + seconds
        let payload = #"{"exp":\#(expiration)}"#

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


