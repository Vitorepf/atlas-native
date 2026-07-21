import Foundation

// MARK: - Types

/// Exclusive código ask-pill face (WAVE-062).
enum AtlasCodeAskPillFace: Equatable {
    case invite
    case anchoring
    case legend

    var productWord: String {
        switch self {
        case .invite: return "invite"
        case .anchoring: return "anchoring"
        case .legend: return "legend"
        }
    }

    var spokenFace: String {
        switch self {
        case .invite:
            return "convidar conversa sobre o repositório"
        case .anchoring:
            return "grafo recortado nos commits da resposta"
        case .legend:
            return "recortado com legenda de âncora"
        }
    }
}

// MARK: - Judgment

/// Pure ask-pill grammar — face · spoken · phaseID · pack.
enum AtlasCodeAskPillJudgment {

    static let pillHint = "abre conversa sobre este repositório"
    static let clearLabel = "mostrar tudo no grafo"
    static let clearHint = "remove o recorte dos commits da resposta"
    static let clearCommitRefLabel = "Limpar referência do commit"
    static let askCommitLabel = "perguntar ao Atlas sobre este commit"
    static func spokenUserQuote(_ quote: String) -> String {
        "sua frase: \(quote)"
    }

    static func face(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> AtlasCodeAskPillFace {
        guard isAnchoring else { return .invite }
        let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !legend.isEmpty { return .legend }
        return .anchoring
    }

    static func spokenPill(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> String {
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        switch face {
        case .invite:
            return "Conversar com o Atlas sobre este repositório"
        case .anchoring:
            return "Conversar com o Atlas, grafo recortado nos commits da resposta"
        case .legend:
            let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return "Conversar com o Atlas, \(legend)"
        }
    }

    /// Animation / phase token (stable for reduceMotion gate).
    static func phaseID(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> String {
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        switch face {
        case .invite:
            return "invite"
        case .anchoring:
            return "anchoring-default"
        case .legend:
            return "anchoring-\(anchorLegend ?? "default")"
        }
    }

    static func packFacts(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        facts.append("ask_pill_face: \(face.productWord)")
        switch face {
        case .invite:
            absences.append("pílula em convite (sem âncora)")
        case .anchoring:
            facts.append("ask_pill_anchoring: true")
            absences.append("âncora sem legenda textual neste recorte")
        case .legend:
            facts.append("ask_pill_anchoring: true")
            if let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines),
               !legend.isEmpty {
                facts.append("ask_pill_legend: \(legend)")
            }
        }
        return (facts, absences)
    }
}
