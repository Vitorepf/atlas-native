import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive Código graph worktrees section face (WAVE-087).
enum AtlasCodeWorktreeSectionFace: Equatable {
    case silence
    case list(Int)

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .list(let n): return "list(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "nenhum worktree publicado"
        case .list(let n):
            let noun = n == 1 ? "worktree" : "worktrees"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure worktree strip grammar — section face · rank · chip spoken · pack.
enum AtlasCodeWorktreeJudgment {

    // MARK: Face

    static func sectionFace(_ worktrees: [AtlasCodeWorktree]) -> AtlasCodeWorktreeSectionFace {
        if worktrees.isEmpty { return .silence }
        return .list(worktrees.count)
    }

    // MARK: Rank — dirty/active first, path-stable

    /// Lower rank = more attention. Non-clean state first, then non-empty state,
    /// then pathLabel stable.
    static func attentionRank(_ worktree: AtlasCodeWorktree) -> Int {
        guard let state = worktree.state?.trimmingCharacters(in: .whitespacesAndNewlines),
              !state.isEmpty else {
            return 20
        }
        let lower = state.lowercased()
        if lower.contains("dirty") || lower.contains("modified") || lower.contains("conflict") {
            return 0
        }
        if lower.contains("active") || lower.contains("locked") {
            return 5
        }
        if lower == "clean" || lower == "pristine" {
            return 15
        }
        return 10
    }

    static func rank(_ worktrees: [AtlasCodeWorktree]) -> [AtlasCodeWorktree] {
        worktrees.enumerated().sorted { lhs, rhs in
            let lr = attentionRank(lhs.element)
            let rr = attentionRank(rhs.element)
            if lr != rr { return lr < rr }
            let lp = lhs.element.pathLabel
            let rp = rhs.element.pathLabel
            if lp != rp { return lp < rp }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    // MARK: Spoken

    static func spokenChip(_ worktree: AtlasCodeWorktree) -> String {
        var parts = [worktree.pathLabel]
        if let branch = worktree.branch?.nonEmpty {
            parts.append("branch \(branch)")
        }
        if let head = worktree.head?.nonEmpty {
            parts.append(String(head.prefix(8)))
        }
        if let state = worktree.state?.nonEmpty {
            parts.append(state)
        }
        return parts.joined(separator: ", ")
    }

    static func spokenSection(_ worktrees: [AtlasCodeWorktree]) -> String {
        let face = sectionFace(worktrees)
        guard case .list = face else { return face.spokenFace }
        let ranked = rank(worktrees)
        var parts = [face.spokenFace]
        if let head = ranked.first {
            parts.append("primeiro \(spokenChip(head))")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        _ worktrees: [AtlasCodeWorktree]
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []
        let face = sectionFace(worktrees)
        facts.append("worktree_face: \(face.productWord)")
        facts.append("worktrees: \(worktrees.count)")
        switch face {
        case .silence:
            absences.append("worktrees não publicados neste load")
        case .list:
            for wt in rank(worktrees).prefix(5) {
                var line = "worktree: \(wt.pathLabel)"
                if let branch = wt.branch?.nonEmpty { line += " · \(branch)" }
                if let state = wt.state?.nonEmpty { line += " · \(state)" }
                facts.append(line)
                anchors.append(spokenChip(wt))
            }
        }
        return (facts, absences, anchors)
    }
}
