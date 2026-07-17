import Foundation
import AtlasCore

// Spoken labels — peel de AutonomosPublicDetailSheet (CICLO C residual honesty).
// Contagens só do payload público; silêncio total sem backlog.
// Count → AutonomosDetailSheet+A11yCount.swift
// Close → AutonomosDetailSheet+A11yClose.swift

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
}
