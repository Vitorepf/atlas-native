import Foundation

// Workspace spoken count — peel de RootChrome+Rows+A11y.

extension RootChromeRowA11y {
    static func workspaceCountPart(_ count: Int) -> String {
        if count == 0 {
            return "nenhuma conversa"
        }
        return "\(count) conversa\(count == 1 ? "" : "s")"
    }
}
