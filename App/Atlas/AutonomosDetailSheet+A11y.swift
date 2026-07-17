import Foundation
import AtlasCore

// Spoken labels — peel de AutonomosPublicDetailSheet (CICLO C residual honesty).
// Contagens só do payload público; silêncio total sem backlog.

extension AutonomosPublicDetailSheet {
    func spokenSheetLabel(backlog: AtlasAutonomosBacklogResponse?) -> String {
        guard let backlog else {
            return "sem projeção pública disponível agora"
        }
        let count = publicItemCount(kind: kind, backlog: backlog)
        let name = kind.title.lowercased()
        if count == 0 {
            return "\(name), nenhum item público neste recorte"
        }
        if count == 1 {
            return "\(name), 1 item público"
        }
        return "\(name), \(count) itens públicos"
    }

    func spokenSheetHint() -> String {
        "lista pública do backlog Autônomos; não afirma execução antes do recibo"
    }

    func spokenCloseLabel() -> String {
        "fechar detalhes de \(kind.title.lowercased())"
    }

    func spokenEmptyLabel() -> String {
        "sem projeção pública disponível agora"
    }

    static func publicItemCount(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> Int {
        switch kind {
        case .workOrders: return backlog.workOrders.count
        case .inbox: return backlog.inboxItems.count
        case .findings: return backlog.findings.items.count
        case .budgets: return 1
        }
    }
}
