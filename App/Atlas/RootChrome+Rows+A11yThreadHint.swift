import Foundation

// Thread hint spoken — peel de RootChrome+Rows+A11yThread.

extension RootChromeRowA11y {
    static func threadHint(isRunning: Bool) -> String {
        isRunning ? "Atlas executando nesta conversa" : "abre a conversa"
    }
}
