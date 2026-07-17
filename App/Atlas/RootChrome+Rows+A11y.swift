import Foundation

/// Spoken labels das linhas da home/workspace — peel de RootChrome+Rows (CICLO C).
/// Contagem zero = «nenhuma conversa»; badge só quando o model marca atenção real.

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

    static func threadSpoken(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> String {
        var parts = [title]
        if isRunning {
            parts.append("Atlas executando")
        } else if messageCount == 0 {
            parts.append("nenhuma mensagem")
        } else {
            parts.append("\(messageCount) mensagem\(messageCount == 1 ? "" : "ns")")
        }
        if isNew && !isRunning {
            parts.append("novo desde a última visita")
        }
        if hasWorkspace {
            parts.append("com workspace")
        }
        return parts.joined(separator: ", ")
    }

    static func threadHint(isRunning: Bool) -> String {
        isRunning ? "Atlas executando nesta conversa" : "abre a conversa"
    }
}
