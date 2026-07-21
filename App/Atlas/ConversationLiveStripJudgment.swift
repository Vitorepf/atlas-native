import Foundation
import AtlasCore

// MARK: - Judgment

/// Pure live ExecutingStrip CTA + compound spoken grammar (WAVE-093).
/// Phase face stays ConversationExecutionPhase; decision/steer sheets stay 053/058 organs.
enum ConversationLiveStripJudgment {

    static let stopLabel = "parar execução"
    static let stopHint = "interrompe a execução ao vivo"
    static let stopButtonTitle = "Parar"

    static let steerLabel = "redirecionar execução"
    static let steerHint = "abre opções para redirecionar a execução ao vivo"
    static let steerButtonTitle = "Redirecionar"

    static let chooseConfirmHint = "confirma a decisão publicada pelo servidor"
    static let chooseMenuHint = "abre as ações de decisão publicadas"

    // MARK: Visibility

    static func showsSteerCTA(decisionRequired: Bool, hasSteerHandler: Bool) -> Bool {
        !decisionRequired && hasSteerHandler
    }

    static func showsChooseCTA(decisionRequired: Bool, actionCount: Int) -> Bool {
        decisionRequired && actionCount > 0
    }

    // MARK: Spoken CTAs

    static func spokenStop() -> String { stopLabel }
    static func spokenStopHint() -> String { stopHint }
    static func spokenSteer() -> String { steerLabel }
    static func spokenSteerHint() -> String { steerHint }
    static func spokenChooseConfirmHint() -> String { chooseConfirmHint }
    static func spokenChooseMenuHint() -> String { chooseMenuHint }

    // MARK: Compound strip label

    static func spokenStrip(
        bubble: ChatBubble,
        decisionRequired: Bool,
        choiceActionCount: Int,
        face: ConversationExecutionFace,
        reconnectSpoken: String?
    ) -> String {
        var parts: [String] = [ConversationExecutionPhase.primarySpoken(for: bubble)]
        if decisionRequired {
            let noun = choiceActionCount == 1 ? "ação" : "ações"
            parts.append("\(choiceActionCount) \(noun) disponíveis")
        }
        if face == .reconnect, let reconnectSpoken, !reconnectSpoken.isEmpty {
            parts.append(reconnectSpoken)
        } else if let p = bubble.executionProgress, face == .running || face == .multiAgent {
            parts.append("passo \(p.current) de \(p.total), \(p.title)")
        } else if let act = bubble.currentActivity, face == .running || face == .multiAgent {
            parts.append(act.title)
        }
        if face != .finished && face != .quiet {
            let events = bubble.activities.count
            parts.append("\(events) evento\(events == 1 ? "" : "s")")
            if let started = bubble.startedAt {
                let secs = max(0, Int(Date().timeIntervalSince(started)))
                parts.append("\(secs) segundos decorridos")
            }
        }
        if let stats = bubble.diffStats {
            parts.append("mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        decisionRequired: Bool,
        choiceActionCount: Int,
        hasSteerHandler: Bool,
        face: ConversationExecutionFace
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("live_strip_phase: \(face.rawValue)")
        facts.append("live_strip_decision_required: \(decisionRequired ? "yes" : "no")")
        facts.append("live_strip_stop: available")
        if showsChooseCTA(decisionRequired: decisionRequired, actionCount: choiceActionCount) {
            facts.append("live_strip_cta: choose")
            facts.append("live_strip_choice_count: \(choiceActionCount)")
        } else {
            absences.append("sem CTA de decisão no strip")
        }
        if showsSteerCTA(decisionRequired: decisionRequired, hasSteerHandler: hasSteerHandler) {
            facts.append("live_strip_cta: steer")
        } else {
            absences.append("steer CTA oculto (decisão ou sem handler)")
        }
        return (facts, absences)
    }
}
