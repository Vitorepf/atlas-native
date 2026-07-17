import Foundation

/// Spoken labels da pílula — peel de AtlasCodeView+AskPill (CICLO C residual honesty).
/// Só fala recorte/âncora real; convite quando o grafo não está filtrado pela resposta.

enum AtlasCodeAskPillA11y {
    static func spokenPill(isAnchoring: Bool, anchorLegend: String?) -> String {
        guard isAnchoring else {
            return "Conversar com o Atlas sobre este repositório"
        }
        let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !legend.isEmpty {
            return "Conversar com o Atlas, \(legend)"
        }
        return "Conversar com o Atlas, grafo recortado nos commits da resposta"
    }

    static func pillPhaseID(isAnchoring: Bool, anchorLegend: String?) -> String {
        isAnchoring ? "anchoring-\(anchorLegend ?? "default")" : "invite"
    }

    static let pillHint = "abre conversa sobre este repositório"
    static let clearLabel = "mostrar tudo no grafo"
    static let clearHint = "remove o recorte dos commits da resposta"
}
