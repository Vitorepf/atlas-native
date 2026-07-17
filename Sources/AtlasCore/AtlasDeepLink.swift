import Foundation

/// Destinos honestos de `atlas://` emitidos por widgets / Live Activity.
/// Parsing puro (sem rede): a casca resolve trace→thread só no case `.execution`.
public enum AtlasDeepLink: Equatable, Sendable {
    case autonomos
    /// Radar do Código (sem repo).
    case codeHome
    case code(repo: String)
    /// Home / Live Now — sem path. Sem inventar thread.
    case executionHome
    /// Trace id (hoje `threadKey` no ActivityAttributes) → resolver via API.
    case execution(traceId: String)

    public static func parse(_ url: URL) -> AtlasDeepLink? {
        guard url.scheme == "atlas" else { return nil }
        switch url.host {
        case "autonomos":
            return .autonomos
        case "code":
            if let repo = firstPathComponent(url), !repo.isEmpty {
                return .code(repo: repo)
            }
            return .codeHome
        case "execution":
            if let trace = firstPathComponent(url), !trace.isEmpty {
                return .execution(traceId: trace)
            }
            return .executionHome
        default:
            return nil
        }
    }

    private static func firstPathComponent(_ url: URL) -> String? {
        url.pathComponents.dropFirst().first
    }
}
