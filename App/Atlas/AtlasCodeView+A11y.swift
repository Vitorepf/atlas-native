import Foundation
import AtlasCore

/// Spoken screen label — peel de AtlasCodeView (CICLO C residual honesty).
/// Loaded → AtlasCodeView+A11y+Loaded.swift

extension AtlasCodeView {
    func spokenCodeScreenLabel() -> String {
        switch model.phase {
        case .idle, .loading:
            return "grafo, \(model.repo), carregando"
        case .failed:
            return "grafo, \(model.repo), falha ao carregar"
        case .loaded:
            return spokenCodeScreenLoadedLabel()
        }
    }

    static let codeScreenHint = "mapa governado; pílula e proveniência só com dados publicados"
}
