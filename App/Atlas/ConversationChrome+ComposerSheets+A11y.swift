import Foundation
import AtlasCore

// Spoken labels — peel dos sheets do composer (CICLO C residual honesty).
// Modo = rótulo local; esforço = opções reais do payload; workspace = threads carregadas.
// Effort → ConversationChrome+ComposerSheets+A11yEffort.swift

enum ComposerSheetA11y {
    static let modeFootnote =
        "rótulo local; ainda não altera roteamento nem payload"

    static func modeLabel(_ key: String, title: String, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "modo \(title), \(state), \(modeFootnote)"
    }

    static func workspaceLabel(name: String, count: Int, selected: Bool) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let state = selected ? "workspace atual" : "disponível"
        return "\(name), \(count) \(noun) carregadas, \(state)"
    }

    static let workspaceEmpty =
        "nenhum workspace nas conversas carregadas; abra uma conversa com pasta ou volte à home"

    static let modeSheetHint = "escolhe um rótulo local; não altera o turno ainda"
    static let effortSheetHint = "escolhe o esforço computacional do próximo envio"
    static let workspaceSheetHint = "escolhe a pasta do próximo envio entre as conversas carregadas"
}
