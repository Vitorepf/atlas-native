import Foundation
import AtlasCore

// MARK: - Judgment

/// Pure conversation mid-thread can_do matrix (WAVE-095).
/// Mirrors Arena 083 / Autônomos 088 — never ongoing-bool alone.
enum ConversationCanDoJudgment {

    /// Live presence snapshot for can_do (casca published signals only).
    struct LiveSignals: Equatable {
        var hasOngoing: Bool
        var hasRunning: Bool
        var hasPaused: Bool
        var hasDecision: Bool
        var decisionActionTitles: [String]
        var hasQueue: Bool
        var queueCount: Int
        var hasPlan: Bool
        var hasLanes: Bool

        static let quiet = LiveSignals(
            hasOngoing: false,
            hasRunning: false,
            hasPaused: false,
            hasDecision: false,
            decisionActionTitles: [],
            hasQueue: false,
            queueCount: 0,
            hasPlan: false,
            hasLanes: false
        )
    }

    static func liveSignals(
        matchingLive: [LiveSessionSnapshot],
        decisionRequired: Bool = false,
        decisionActionTitles: [String] = [],
        queueCount: Int = 0,
        hasPlan: Bool = false,
        laneCount: Int = 0
    ) -> LiveSignals {
        let ongoing = matchingLive.contains { $0.timing != .finished }
        return LiveSignals(
            hasOngoing: ongoing,
            hasRunning: matchingLive.contains { $0.timing == .running },
            hasPaused: matchingLive.contains { $0.timing == .paused },
            hasDecision: decisionRequired && !decisionActionTitles.isEmpty,
            decisionActionTitles: decisionActionTitles,
            hasQueue: queueCount > 0,
            queueCount: queueCount,
            hasPlan: hasPlan,
            hasLanes: laneCount > 0
        )
    }

    /// can_do from published CTAs — never invent stop/steer/choose.
    static func occasionCanDo(_ signals: LiveSignals) -> AgenticOccasionPack.CanDo {
        // Decision Escolher is face CTA (local), not NL write.
        if signals.hasDecision {
            return .faceCTALocal
        }
        // Live run/pause: strip exposes stop (+ steer when no decision).
        if signals.hasRunning || signals.hasPaused {
            return .ctaOnlyRunStop
        }
        // Ongoing edge (unknown timing) — face chrome may exist.
        if signals.hasOngoing {
            return .faceCTALocal
        }
        // Quiet thread: read only (queue alone does not authorize write).
        if signals.hasQueue {
            return .readChat
        }
        return .readChat
    }

    static func packFacts(_ signals: LiveSignals) -> (facts: [String], absences: [String], canDo: AgenticOccasionPack.CanDo) {
        let canDo = occasionCanDo(signals)
        var facts: [String] = []
        var absences: [String] = []
        facts.append("can_do: \(canDo.rawValue)")
        facts.append("live_ongoing: \(signals.hasOngoing ? "yes" : "no")")
        facts.append("live_running: \(signals.hasRunning ? "yes" : "no")")
        facts.append("live_paused: \(signals.hasPaused ? "yes" : "no")")
        facts.append("decision_required: \(signals.hasDecision ? "yes" : "no")")
        if signals.hasDecision {
            facts.append("decision_actions: \(signals.decisionActionTitles.count)")
            for title in signals.decisionActionTitles.prefix(6) {
                facts.append("decision_action: \(title)")
            }
        } else {
            absences.append("sem decisão Escolher publicada neste recorte")
        }
        if signals.hasQueue {
            facts.append("queue_followups: \(signals.queueCount)")
        } else {
            absences.append("fila de follow-up vazia neste recorte")
        }
        if !signals.hasPlan {
            absences.append("plano de execução não publicado neste recorte")
        }
        if !signals.hasLanes {
            absences.append("sem agent lanes publicadas neste recorte")
        }
        if signals.hasOngoing && !signals.hasRunning && !signals.hasPaused && !signals.hasDecision {
            absences.append("live sem stop/decision CTA tipada — can_do face cauteloso")
        }
        if !signals.hasOngoing {
            absences.append("thread quieta — can_do read_chat (sem face CTA inventada)")
        }
        absences.append("NL de chat ainda não autoriza tools de escrita no wire")
        return (facts, absences, canDo)
    }
}
