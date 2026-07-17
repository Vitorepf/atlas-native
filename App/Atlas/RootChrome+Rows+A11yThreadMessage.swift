import Foundation

// Message count fragments — peel de RootChrome+Rows+A11yThreadStatus.

extension RootChromeRowA11y {
    static func threadMessageParts(messageCount: Int, isRunning: Bool) -> [String] {
        if isRunning {
            return ["Atlas executando"]
        }
        if messageCount == 0 {
            return ["nenhuma mensagem"]
        }
        return ["\(messageCount) mensagem\(messageCount == 1 ? "" : "ns")"]
    }
}
