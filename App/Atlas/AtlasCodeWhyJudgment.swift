import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive file-biography (H1 Why) face (WAVE-056).
enum AtlasCodeWhyFace: Equatable {
    case loading
    case failed(String?)
    case empty
    case timeline(Int)
    case truncated(shown: Int, total: Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .timeline: return "timeline"
        case .truncated: return "truncated"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "lendo a história do arquivo"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "biografia indisponível, \(message)"
            }
            return "biografia indisponível"
        case .empty:
            return "este arquivo não tem história neste recorte"
        case .timeline(let n):
            return n == 1
                ? "1 commit na biografia do arquivo"
                : "\(n) commits na biografia do arquivo"
        case .truncated(let shown, let total):
            return "mostrando \(shown) de \(total) commits, história truncada"
        }
    }
}

// MARK: - Judgment

/// Pure Why biography grammar — face · spoken · pack.
enum AtlasCodeWhyJudgment {

    static func face(
        phase: LoadPhase,
        why: AtlasCodeWhy?,
        message: String?
    ) -> AtlasCodeWhyFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed:
            return .failed(message)
        case .loaded:
            guard let why else { return .empty }
            if why.commits.isEmpty { return .empty }
            if why.truncated {
                return .truncated(shown: why.commits.count, total: why.commitsTotal)
            }
            return .timeline(why.commits.count)
        }
    }

    /// Convenience when model is available on MainActor.
    @MainActor
    static func face(model: AtlasCodeWhyModel) -> AtlasCodeWhyFace {
        face(phase: model.phase, why: model.why, message: model.message)
    }

    static func truncatedBanner(_ why: AtlasCodeWhy) -> String? {
        guard why.truncated else { return nil }
        return "mostrando \(why.commits.count) de \(why.commitsTotal) · história truncada"
    }

    static func spokenSheet(file: String, face: AtlasCodeWhyFace) -> String {
        "biografia do arquivo \(file), \(face.spokenFace)"
    }

    static func spokenHeader(file: String, face: AtlasCodeWhyFace) -> String {
        switch face {
        case .truncated(let shown, let total):
            return "\(file), mostrando \(shown) de \(total)"
        default:
            return file
        }
    }

    static func contentPhaseID(face: AtlasCodeWhyFace) -> String {
        switch face {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .timeline(let n): return "timeline-\(n)"
        case .truncated(let shown, let total): return "truncated-\(shown)-\(total)"
        }
    }

    static func packFacts(
        file: String,
        phase: LoadPhase,
        why: AtlasCodeWhy?,
        message: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase, why: why, message: message)
        facts.append("why_face: \(face.productWord)")
        facts.append("why_file: \(file)")
        switch face {
        case .loading:
            absences.append("biografia ainda carregando")
        case .failed(let msg):
            absences.append("biografia falhou")
            if let msg, !msg.isEmpty { facts.append("why_error: \(msg)") }
        case .empty:
            absences.append("sem commits na biografia deste recorte")
        case .timeline(let n):
            facts.append("why_commits: \(n)")
        case .truncated(let shown, let total):
            facts.append("why_commits_shown: \(shown)")
            facts.append("why_commits_total: \(total)")
            facts.append("why_truncated: true")
        }
        return (facts, absences)
    }
}
