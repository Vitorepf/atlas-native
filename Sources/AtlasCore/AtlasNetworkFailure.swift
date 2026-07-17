import Foundation

public enum AtlasNetworkFailureKind: String, Sendable, Equatable {
    case offline
    case timedOut
    case connectionRefused
    case connectionLost
    case unauthorized
    case maintenance
    case serverUnavailable
    case other
}

public func atlasNetworkFailureKind(for error: Error) -> AtlasNetworkFailureKind {
    if let api = error as? AtlasApiError {
        switch api.status {
        case 401, 403: return .unauthorized
        case 408: return .timedOut
        case 503 where api.retryAfterSeconds != nil: return .maintenance
        case 429, 500...599: return .serverUnavailable
        default: return .other
        }
    }
    if let url = error as? URLError {
        switch url.code {
        case .notConnectedToInternet, .internationalRoamingOff, .dataNotAllowed:
            return .offline
        case .timedOut:
            return .timedOut
        case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return .connectionRefused
        case .networkConnectionLost:
            return .connectionLost
        case .userAuthenticationRequired, .userCancelledAuthentication:
            return .unauthorized
        default:
            return .other
        }
    }
    return .other
}
