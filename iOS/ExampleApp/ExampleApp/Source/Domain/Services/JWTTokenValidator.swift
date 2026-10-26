//
import Foundation

struct JWTTokenValidator: TokenValidator {

    nonisolated func isValid(_ accessToken: String) -> Bool {

        let parts = accessToken.split(separator: ".")

        guard parts.count == 3 else {
            return false
        }

        let payload = String(parts[1])

        var base64 = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        while base64.count % 4 != 0 {
            base64.append("=")
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(
                with: data
              ) as? [String: Any],
              let expiration = json["exp"] as? TimeInterval else {
            return false
        }

        print("JWT expiration:", expiration)
        print("Current time:", Date().timeIntervalSince1970)
        print("Token valid:", Date().timeIntervalSince1970 < expiration)

        return Date().timeIntervalSince1970 < expiration
    }

    nonisolated func expirationDate(for accessToken: String) -> Date? {

        let parts = accessToken.split(separator: ".")

        guard parts.count == 3 else {
            return nil
        }

        let payload = String(parts[1])

        var base64 = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        while base64.count % 4 != 0 {
            base64.append("=")
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(
                with: data
              ) as? [String: Any],
              let expiration = json["exp"] as? TimeInterval else {
            return nil
        }

        return Date(timeIntervalSince1970: expiration)
    }

    nonisolated func needsRefresh(
        _ accessToken: String,
        skew: TimeInterval = 60
    ) -> Bool {
        guard let expirationDate = expirationDate(for: accessToken) else {
            return true
        }

        return expirationDate.timeIntervalSinceNow <= skew
    }
}

