import Foundation

/// Spoken labels das linhas da home/workspace — peel de RootChrome+Rows (CICLO C).
/// Contagem zero = «nenhuma conversa»; badge só quando o model marca atenção real.
/// Thread → RootChrome+Rows+A11yThread.swift

enum RootChromeRowA11y {
    static func workspaceSpoken(
        name: String,
        count: Int?,
        detail: String?,
        badge: Bool
    ) -> String {
        var parts = [name]
        if let count {
            if count == 0 {
                parts.append("nenhuma conversa")
            } else {
                parts.append("\(count) conversa\(count == 1 ? "" : "s")")
            }
        }
        if let detail, !detail.isEmpty {
            parts.append(detail)
        }
        if badge {
            parts.append("atenção necessária")
        }
        return parts.joined(separator: ", ")
    }
}
