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

    // MARK: Row spoken (WAVE-110 · peel from LiveNowRow)

    static func hubPositionPrefix(index: Int?, count: Int?) -> String {
        guard let index, let count, count >= 2 else { return "" }
        return "sessão \(index + 1) de \(count), "
    }

    static func remoteSuffix(isRemote: Bool) -> String {
        isRemote ? ", remota em outra superfície" : ""
    }

    static func formatClock(
        elapsedMs: Int?,
        runningSince: Date?,
        now: Date,
        paused: Bool
    ) -> String {
        guard let base = elapsedMs else { return "—" }
        var ms = base
        if !paused, let since = runningSince {
            ms += max(0, Int(now.timeIntervalSince(since) * 1000))
        }
        let s = ms / 1000
        return s >= 3600
            ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
            : String(format: "%d:%02d", s / 60, s % 60)
    }

    static func spokenClock(for session: LiveSessionSnapshot, now: Date) -> String? {
        guard session.elapsedActiveMs != nil else { return nil }
        return formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: session.runningSince,
            now: now,
            paused: session.timing == .paused
        )
    }

    static func pauseAgeHours(for session: LiveSessionSnapshot, now: Date) -> Int? {
        guard session.timing == .paused, let pauseTimestamp = session.pauseTimestamp else { return nil }
        let seconds = max(0, now.timeIntervalSince(pauseTimestamp))
        guard seconds >= 30 * 60 else { return nil }
        return max(1, Int(seconds / 3600))
    }

    static func spokenRow(
        session: LiveSessionSnapshot,
        hubIndex: Int?,
        hubCount: Int?,
        now: Date = .now
    ) -> String {
        let prefix = hubPositionPrefix(index: hubIndex, count: hubCount)
        if let active = spokenActive(session: session, prefix: prefix, now: now) {
            return active
        }
        return spokenFinished(session: session, prefix: prefix)
    }

    static func spokenActive(
        session: LiveSessionSnapshot,
        prefix: String,
        now: Date
    ) -> String? {
        switch session.timing {
        case .running:
            return spokenRunning(session: session, prefix: prefix, now: now)
        case .paused:
            return spokenPaused(session: session, prefix: prefix, now: now)
        default:
            return nil
        }
    }

    static func spokenRunning(
        session: LiveSessionSnapshot,
        prefix: String,
        now: Date
    ) -> String {
        let faceWord = ConversationExecutionPhase.primarySpoken(.running)
        let detail = session.phaseTitle
        let remote = remoteSuffix(isRemote: session.isRemote)
        if let clock = spokenClock(for: session, now: now) {
            return "\(prefix)\(session.title), \(faceWord)\(remote), \(detail), há \(clock)"
        }
        return "\(prefix)\(session.title), \(faceWord)\(remote), \(detail), tempo ativo indisponível"
    }

    static func spokenPaused(
        session: LiveSessionSnapshot,
        prefix: String,
        now: Date
    ) -> String {
        let faceWord = ConversationExecutionPhase.primarySpoken(.paused)
        let detail = session.phaseTitle
        let remote = remoteSuffix(isRemote: session.isRemote)
        let age = pauseAgeHours(for: session, now: now).map { ", há \($0) horas" } ?? ""
        if let clock = spokenClock(for: session, now: now) {
            return "\(prefix)\(session.title), \(faceWord)\(remote), \(detail), em \(clock)\(age)"
        }
        return "\(prefix)\(session.title), \(faceWord)\(remote), \(detail), tempo ativo indisponível\(age)"
    }

    static func spokenFinished(session: LiveSessionSnapshot, prefix: String) -> String {
        let faceWord = ConversationExecutionPhase.primarySpoken(.finished)
        let remote = remoteSuffix(isRemote: session.isRemote)
        return "\(prefix)\(session.title), \(faceWord)\(remote), \(session.phaseTitle)"
    }

    static func spokenClockAccessibility(session: LiveSessionSnapshot, now: Date) -> String {
        guard let clock = spokenClock(for: session, now: now) else {
            return "tempo ativo indisponível"
        }
        return session.timing == .paused
            ? "tempo ativo congelado em \(clock)"
            : "tempo ativo \(clock)"
    }

    // MARK: Pack

    /// Ranked live anchors for HomeAskContext (product face words via occasion pack).
    @MainActor
    static func packLiveAnchors(
        local: [LiveSessionSnapshot],
        remote: [LiveSessionSnapshot] = [],
        limit: Int = 5
    ) -> (facts: [String], anchors: [String], absences: [String]) {
        var facts: [String] = []
        var anchors: [String] = []
        var absences: [String] = []
        let ranked = rank(local: local, remote: remote)
        facts.append("sessoes_vivas: \(ranked.count)")
        facts.append("live_now_face: \(sectionFace(count: ranked.count).productWord)")
        if ranked.isEmpty {
            absences.append("nenhuma sessão viva na home")
        } else {
            for s in ranked.prefix(limit) {
                anchors.append(ConversationOccasionPack.liveAnchorLine(s))
            }
        }
        return (facts, anchors, absences)
    }
}
