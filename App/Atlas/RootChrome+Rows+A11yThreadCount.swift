import Foundation

// Message count state — peel de RootChrome+Rows+A11yThreadMessage.

extension RootChromeRowA11y {
    static func spokenThreadMessageCount(_ messageCount: Int) -> [String] {
        if messageCount == 0 {
            return ["nenhuma mensagem"]
        }
        return ["\(messageCount) mensagem\(messageCount == 1 ? "" : "ns")"]
    }
}
