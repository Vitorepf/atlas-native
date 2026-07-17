import Foundation

// Thread status fragments — peel de RootChrome+Rows+A11yThread.

extension RootChromeRowA11y {
    static func threadStatusParts(
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> [String] {
        var parts: [String] = []
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
        return parts
    }
}
