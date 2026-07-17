import AtlasCore
import SwiftUI

/// Spoken labels do espelho — peel de AtlasCodeMirrorCard (CICLO C residual honesty).
/// Só fala host e contagens reais do payload; ausência nunca vira zero fabricado.

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseID: String {
        switch response.state {
        case .mirrored: return "mirrored"
        case .pending(let commits): return "pending-\(commits)"
        case .blocked(let rules): return "blocked-\(rules.joined(separator: "-"))"
        case .noMirror: return "no-mirror"
        case .unknown: return "unknown"
        }
    }

    func spokenMirrorLabel() -> String {
        var parts: [String] = ["Espelho"]
        switch response.state {
        case .mirrored:
            parts.append("tudo espelhado, verdade no Mac")
        case .pending(let commits):
            parts.append("\(commits) commit\(commits == 1 ? "" : "s") ainda só no Mac")
        case .blocked(let rules):
            parts.append("bloqueado, segredo detectado")
            if !rules.isEmpty {
                parts.append("regras \(rules.joined(separator: ", "))")
            }
        case .noMirror:
            parts.append("sem espelho configurado")
        case .unknown:
            parts.append("estado ainda não conhecido")
        }
        if let host = response.mirror?.host, !host.isEmpty {
            parts.append("host \(host)")
        }
        return parts.joined(separator: ", ")
    }

    static let mirrorHint = "cópia remota do repositório e varredura de segredos no Mac"
}
