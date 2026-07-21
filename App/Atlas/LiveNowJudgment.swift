import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive home LiveNow section face (WAVE-064).
enum LiveNowSectionFace: Equatable {
    case empty
    case single
    case hub(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .single: return "single"
        case .hub: return "hub"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem sessões vivas"
        case .single:
            return "vivo agora"
        case .hub(let count):
            return "vivo agora, \(count) sessões vivas"
        }
    }
}

// MARK: - Judgment

/// Pure LiveNow attention grammar — merge · rank · head · spoken · pack.
enum LiveNowJudgment {

    // MARK: Merge (local first; remote de-duped by threadId)

    static func merge(
        local: [LiveSessionSnapshot],
        remote: [LiveSessionSnapshot]
    ) -> [LiveSessionSnapshot] {
        local + filteredRemote(local: local, remote: remote)
    }

    static func filteredRemote(
        local: [LiveSessionSnapshot],
        remote: [LiveSessionSnapshot]
    ) -> [LiveSessionSnapshot] {
        var seenThreads = Set(local.compactMap { $0.threadId?.rawValue })
        var seenRemoteIDs: Set<String> = []
        return remote.filter { session in
            if let thread = session.threadId?.rawValue {
                guard !seenThreads.contains(thread) else { return false }
                seenThreads.insert(thread)
                return true
            }
            return seenRemoteIDs.insert(session.id).inserted
        }
    }

    // MARK: Face attention rank (WAVE-023 law)

    /// Lower = higher attention.
    static func attentionRank(_ face: ConversationExecutionFace) -> Int {
        switch face {
        case .running, .multiAgent: return 0
        case .paused, .reconnect: return 1
        case .finished: return 2
        case .quiet: return 3
        }
    }

    /// Ranked attention order — face precedence, stable merge order as tie.
    static func rank(_ sessions: [LiveSessionSnapshot]) -> [LiveSessionSnapshot] {
        sessions.enumerated().sorted { lhs, rhs in
            let lf = ConversationExecutionPhase.face(for: lhs.element)
            let rf = ConversationExecutionPhase.face(for: rhs.element)
            let lr = attentionRank(lf)
            let rr = attentionRank(rf)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func rank(
        local: [LiveSessionSnapshot],
        remote: [LiveSessionSnapshot]
    ) -> [LiveSessionSnapshot] {
        rank(merge(local: local, remote: remote))
    }

    /// Deep-link / Seguir head — first ranked session with threadId.
    static func headForOpen(
        local: [LiveSessionSnapshot],
        remote: [LiveSessionSnapshot]
    ) -> LiveSessionSnapshot? {
        rank(local: local, remote: remote).first { $0.threadId != nil }
    }

    // MARK: Chrome

    static let remoteSurfaceBadgeLabel = "sessão remota em outra superfície"

    // MARK: Section face + spoken

    static func sectionFace(count: Int) -> LiveNowSectionFace {
        if count <= 0 { return .empty }
        if count == 1 { return .single }
        return .hub(count)
    }

    static func spokenSection(
        isHub: Bool,
        count: Int,
        remoteCount: Int
    ) -> String {
        let face = sectionFace(count: count)
        switch face {
        case .empty:
            return face.spokenFace
        case .single:
            return face.spokenFace
        case .hub:
            var label = face.spokenFace
            if remoteCount > 0 {
                label += ", \(remoteCount) remota\(remoteCount == 1 ? "" : "s") em outra superfície"
            }
            return label
        }
    }

}
