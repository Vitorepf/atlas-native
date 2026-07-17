import Foundation
import AtlasCore

// Workspace spoken — peel de ConversationChrome+ComposerSheets+A11y.

extension ComposerSheetA11y {
    static func workspaceLabel(name: String, count: Int, selected: Bool) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let state = selected ? "workspace atual" : "disponível"
        return "\(name), \(count) \(noun) carregadas, \(state)"
    }

    static let workspaceEmpty =
        "nenhum workspace nas conversas carregadas; abra uma conversa com pasta ou volte à home"
}
