import Foundation

enum APIEndpoint {
    case login
    case currentuser
    case refresh
}

extension APIEndpoint {
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .currentuser:
            return "/currentuser"
        case .refresh:
            return "/auth/refresh"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .currentuser:
            return .get
        case .refresh:
            return .post
        }
    }
}
