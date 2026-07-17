import AtlasCore

// Rotas: um workspace (repo), uma thread existente, ou conversa nova.
enum Route: Hashable {
    case workspace(key: String?, title: String)
    /// M0 · o grafo de UM repositório, escolhido no radar (M3).
    case codeGraph(repo: String)
    case thread(id: ThreadID, title: String)
    case new
    case conversas
    case search
    case autonomos
    case arena
    case code
}
