import Foundation
import AtlasCore
import SwiftUI

// WAVE-146

extension LiveNowJudgment {
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

    // MARK: Pack (WAVE-183 · packFacts canon)

    /// Ranked live anchors for HomeAskContext (product face words via occasion pack).
    @MainActor
    static func packFacts(
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

    /// Compat shim — prefer `packFacts`.
    @MainActor
    static func packLiveAnchors(
        local: [LiveSessionSnapshot],
        remote: [LiveSessionSnapshot] = [],
        limit: Int = 5
    ) -> (facts: [String], anchors: [String], absences: [String]) {
        packFacts(local: local, remote: remote, limit: limit)
    }

}
