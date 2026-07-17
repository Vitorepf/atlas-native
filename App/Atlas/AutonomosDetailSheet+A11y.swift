import Foundation
import AtlasCore

// Spoken labels — peel de AutonomosPublicDetailSheet (CICLO C residual honesty).
// Contagens só do payload público; silêncio total sem backlog.
// Count → AutonomosDetailSheet+A11ySheetCount.swift
// Close → AutonomosDetailSheet+A11yClose.swift

extension AutonomosPublicDetailSheet {
    func spokenSheetLabel(backlog: AtlasAutonomosBacklogResponse?) -> String {
        guard let backlog else {
            return "sem projeção pública disponível agora"
        }
        let count = publicItemCount(kind: kind, backlog: backlog)
        return spokenSheetCountLabel(name: kind.title.lowercased(), count: count)
    }
}
