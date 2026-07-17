import Foundation
import AtlasCore

/// Spoken screen label — peel de AtlasCodeView (CICLO C residual honesty).

extension AtlasCodeView {
    func spokenCodeScreenLabel() -> String {
        switch model.phase {
        case .idle, .loading:
            return "grafo, \(model.repo), carregando"
        case .failed:
            return "grafo, \(model.repo), falha ao carregar"
        case .loaded:
            let n = model.graph?.nodes.count ?? 0
            if n == 0 { return "grafo, \(model.repo), sem commits neste recorte" }
            return "grafo, \(model.repo), \(n) commit\(n == 1 ? "" : "s")"
        }
    }

    static let codeScreenHint = "mapa governado; pílula e proveniência só com dados publicados"
}
