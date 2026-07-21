import Foundation
import AtlasCore

// MARK: - Judgment

/// Pure Autônomos can_do matrix (WAVE-088) — never always faceCTALocal.
/// Mirrors Arena WAVE-083 honesty: NL never tool write; CTA only when face has controls.
enum AutonomosCanDoJudgment {

    /// Exclusive can_do from published control + destination + decisions.
    static func occasionCanDo(
        destination: AutonomosDestination?,
        controlFace: AutonomosRunControlFace,
        canControl: Bool,
        decisionCount: Int,
        hasUnit: Bool
    ) -> AgenticOccasionPack.CanDo {
        // Loop stoppable only when registered control + live/paused arms.
        if canControl {
            switch controlFace {
            case .running, .paused:
                return .ctaOnlyRunStop
            case .idle, .killed:
                return .faceCTALocal
            case .unbound, .unregistered:
                break
            }
        }

        if let destination {
            switch destination {
            case .decisions, .decisionInbox, .decisionOrder:
                return decisionCount > 0 ? .faceCTALocal : .readChat
            case .incident:
                // Transfer/health CTAs may exist; never NL write.
                return canControl ? .faceCTALocal : .readChat
            case .evolution, .moment:
                return .readChat
            case .hub:
                return canControl ? .faceCTALocal : .readChat
            }
        }

        // Catalog / no destination.
        if !hasUnit {
            return .statusOnly
        }
        if canControl {
            return .faceCTALocal
        }
        return .readChat
    }

    static func packFacts(
        destination: AutonomosDestination?,
        controlFace: AutonomosRunControlFace,
        canControl: Bool,
        decisionCount: Int,
        hasUnit: Bool
    ) -> (facts: [String], absences: [String], canDo: AgenticOccasionPack.CanDo) {
        let canDo = occasionCanDo(
            destination: destination,
            controlFace: controlFace,
            canControl: canControl,
            decisionCount: decisionCount,
            hasUnit: hasUnit
        )
        var facts: [String] = []
        var absences: [String] = []
        facts.append("can_do: \(canDo.rawValue)")
        facts.append("can_control: \(canControl ? "yes" : "no")")
        facts.append("control_face: \(controlFace.productWord)")
        facts.append("decision_count: \(decisionCount)")

        if !canControl {
            absences.append("canControl=false — CTA de loop não é write NL")
        }
        if let destination {
            switch destination {
            case .decisions, .decisionInbox, .decisionOrder:
                if decisionCount == 0 {
                    absences.append("sem decisões publicadas — não invente inbox")
                }
            case .evolution, .moment:
                absences.append("destino de leitura (evolução/momento) — can_do read_chat")
            default:
                break
            }
        }
        if !hasUnit {
            absences.append("nenhum Autônomo aberto — can_do status/read only")
        }
        switch canDo {
        case .ctaOnlyRunStop, .faceCTALocal:
            absences.append("NL de chat ainda não autoriza tools de escrita no wire")
        case .readChat, .statusOnly:
            break
        }
        return (facts, absences, canDo)
    }
}
