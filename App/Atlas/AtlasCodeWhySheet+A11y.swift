import Foundation
import AtlasCore

/// Spoken labels — peel de AtlasCodeWhySheet (CICLO C residual honesty).
/// Só fala payload real de `/api/code/why`; truncação e proveniência ausente não inventam ledger.

extension AtlasCodeWhySheet {
    var whyContentPhaseID: String {
        switch model.phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded:
            guard let why = model.why else { return "loaded-nil" }
            return why.commits.isEmpty ? "empty" : "timeline-\(why.commits.count)"
        }
    }

    var whySheetSpokenLabel: String {
        var parts = ["biografia do arquivo, \(file)"]
        if model.phase == .loaded, let why = model.why {
            if why.commits.isEmpty {
                parts.append("sem história neste recorte")
            } else {
                var history = "\(why.commits.count) commit\(why.commits.count == 1 ? "" : "s")"
                if why.truncated { history += " de \(why.commitsTotal), história truncada" }
                parts.append(history)
            }
        }
        return parts.joined(separator: ", ")
    }

    var whyHeaderSpokenLabel: String {
        guard let why = model.why, why.truncated else { return file }
        return "\(file), mostrando \(why.commits.count) de \(why.commitsTotal)"
    }

    func spokenLoading() -> String { "lendo a história do arquivo" }

    func spokenFailed() -> String {
        if let message = model.message, !message.isEmpty {
            return "biografia indisponível, \(message)"
        }
        return "biografia indisponível"
    }

    func spokenEmptyHistory() -> String { "este arquivo não tem história neste recorte" }

    func spokenCommit(_ commit: AtlasCodeWhy.Commit) -> String {
        var parts: [String] = []
        if let quote = commit.provenance?.quote { parts.append(quote) }
        parts.append(commit.agentLabel)
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        if !commit.subject.isEmpty { parts.append(commit.subject) }
        return parts.joined(separator: ", ")
    }

    static let sheetHint = "histórico de commits e proveniência registrada pelo Atlas"
}
