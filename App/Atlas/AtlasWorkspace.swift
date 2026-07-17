import SwiftUI
import AtlasCore

struct Workspace: Identifiable, Hashable {
    let id: String     // chave = nome de pasta minúsculo
    let name: String   // exibição
    let count: Int
}

// Área/modo de uma conversa. Heurística por surface + metadata (o dado de modo é
// esparso hoje; conforme o servidor popular current_mode/routing_domain, afina).
enum AtlasArea: String, CaseIterable, Identifiable {
    case tudo, operacional, autonomos, programacao
    var id: String { rawValue }
    var label: String {
        switch self {
        case .tudo: return "Tudo"
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        }
    }

    static func of(_ t: AtlasAiThread) -> AtlasArea {
        let surface = t.surface.lowercased()
        let mode = (t.metadata?["current_mode"]?.stringValue
            ?? t.metadata?["atlas_mode"]?.stringValue
            ?? t.metadata?["workflow_mode"]?.stringValue ?? "").lowercased()
        let domain = (t.metadata?["routing_domain"]?.stringValue ?? "").lowercased()
        if surface.contains("code") || domain.contains("eng") || domain.contains("prog") || mode.contains("program") {
            return .programacao
        }
        if mode.contains("auto") || mode.contains("loop") || (t.metadata?["awis_automation"]?.boolValue ?? false) {
            return .autonomos
        }
        return .operacional
    }
}
