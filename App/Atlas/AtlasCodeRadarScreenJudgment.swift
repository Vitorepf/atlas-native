import Foundation

// MARK: - Types

/// Exclusive multi-repo Radar screen face (WAVE-067).
enum AtlasCodeRadarScreenFace: Equatable {
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
            return "lendo o workspace"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "workspace indisponível, \(message)"
            }
            return "workspace indisponível"
        case .empty:
            return "nenhum repositório neste workspace"
        case .ready(let n):
            return n == 1 ? "1 repositório" : "\(n) repositórios"
        }
    }

    var phaseID: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "loaded-empty"
        case .ready(let n): return "loaded-\(n)"
        }
    }
}

// MARK: - Judgment

/// Pure Radar screen load grammar — face · spoken · phaseID · pack.
enum AtlasCodeRadarScreenJudgment {

    static let shellHint = "pastas, recentes e sem retorno verificados do seu código"

    static func face(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> AtlasCodeRadarScreenFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed(let message):
            let published = failMessage ?? message
            return .failed(published.isEmpty ? nil : published)
        case .loaded:
            let n = repositoryCount ?? 0
            if n <= 0 { return .empty }
            return .ready(n)
        }
    }

    static func spokenShell(face: AtlasCodeRadarScreenFace) -> String {
        "Código, workspace do operador, \(face.spokenFace)"
    }

    static func spokenShell(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> String {
        spokenShell(
            face: face(
                phase: phase,
                repositoryCount: repositoryCount,
                failMessage: failMessage
            )
        )
    }

    static func packFacts(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            phase: phase,
            repositoryCount: repositoryCount,
            failMessage: failMessage
        )
        facts.append("radar_screen_face: \(face.productWord)")
        switch face {
        case .loading:
            absences.append("workspace radar ainda carregando")
        case .failed(let msg):
            absences.append("workspace radar falhou")
            if let msg, !msg.isEmpty { facts.append("radar_error: \(msg)") }
        case .empty:
            absences.append("workspace sem repositórios")
            facts.append("radar_repos: 0")
        case .ready(let n):
            facts.append("radar_repos: \(n)")
        }
        return (facts, absences)
    }
}
