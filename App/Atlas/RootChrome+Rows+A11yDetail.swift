import Foundation

// Workspace spoken detail + badge — peel de RootChrome+Rows+A11y.

extension RootChromeRowA11y {
    static func workspaceDetailParts(detail: String?, badge: Bool) -> [String] {
        var parts: [String] = []
        if let detail, !detail.isEmpty {
            parts.append(detail)
        }
        if badge {
            parts.append("atenção necessária")
        }
        return parts
    }
}
