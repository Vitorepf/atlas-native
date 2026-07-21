import Foundation

// MARK: - Types

/// Exclusive código graph-screen face (WAVE-061).
enum AtlasCodeGraphScreenFace: Equatable {
    case loading
    case failed(String?)
    case empty
    case ready(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "carregando"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "falha ao carregar, \(message)"
            }
            return "falha ao carregar"
        case .empty:
            return "sem commits neste recorte"
        case .ready(let n):
            return n == 1 ? "1 commit" : "\(n) commits"
        }
    }
}

// MARK: - Judgment

/// Pure graph-screen load grammar — face · spoken · pack.
enum AtlasCodeGraphLoadJudgment {

    static func face(
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil
    ) -> AtlasCodeGraphScreenFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed(let message):
            let published = failMessage ?? message
            return .failed(published.isEmpty ? nil : published)
        case .loaded:
            if nodeCount <= 0 { return .empty }
            return .ready(nodeCount)
        }
    }

    /// Screen spoken: "grafo, {repo}, {face spoken}".
    static func spokenScreen(repo: String, face: AtlasCodeGraphScreenFace) -> String {
        "grafo, \(repo), \(face.spokenFace)"
    }

    static func spokenScreen(
        repo: String,
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil
    ) -> String {
        spokenScreen(
            repo: repo,
            face: face(phase: phase, nodeCount: nodeCount, failMessage: failMessage)
        )
    }

    static func packFacts(
        repo: String,
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil,
        isAnchoring: Bool = false
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase, nodeCount: nodeCount, failMessage: failMessage)
        facts.append("graph_screen_face: \(face.productWord)")
        facts.append("graph_repo: \(repo)")
        switch face {
        case .loading:
            absences.append("grafo ainda carregando")
        case .failed(let msg):
            absences.append("grafo falhou ao carregar")
            if let msg, !msg.isEmpty { facts.append("graph_error: \(msg)") }
        case .empty:
            absences.append("sem commits neste recorte do grafo")
            facts.append("graph_nodes: 0")
        case .ready(let n):
            facts.append("graph_nodes: \(n)")
        }
        if isAnchoring {
            facts.append("graph_anchoring: true")
        }
        return (facts, absences)
    }
}
