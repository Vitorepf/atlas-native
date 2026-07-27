import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: AutonomosJudgments fused

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
        hasUnit: Bool,
        canRevert: Bool = false
    ) -> (facts: [String], absences: [String], canDo: AgenticOccasionPack.CanDo) {
        var canDo = occasionCanDo(
            destination: destination,
            controlFace: controlFace,
            canControl: canControl,
            decisionCount: decisionCount,
            hasUnit: hasUnit
        )
        // WAVE-159: merge-proved veto is a face CTA (sheet), never NL write.
        // Elevate readChat → faceCTALocal when veto is the only control published.
        if canRevert, canDo == .readChat || canDo == .statusOnly {
            canDo = .faceCTALocal
        }
        var facts: [String] = []
        var absences: [String] = []
        facts.append("can_do: \(canDo.rawValue)")
        facts.append("can_control: \(canControl ? "yes" : "no")")
        facts.append("control_face: \(controlFace.productWord)")
        facts.append("decision_count: \(decisionCount)")
        facts.append("can_revert: \(canRevert ? "yes" : "no")")

        if !canControl {
            absences.append("canControl=false — CTA dos Autônomos não é write NL")
        }
        if canRevert {
            absences.append("veto retroativo só no sheet de recibo — NL não reverte ciclo")
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
// MARK: - Types

/// Exclusive multi-area bind face (WAVE-065).
enum AutonomosAreaBindFace: Equatable {
    /// Zero registered areas — silence, no theater.
    case none
    /// Exactly one registered (or defaultArea match) — auto-bind path.
    case auto
    /// N>1 registered and nothing selected — operator must choose.
    case needsBind(Int)
    /// Area selected.
    case bound(String)

    var productWord: String {
        switch self {
        case .none: return "none"
        case .auto: return "auto"
        case .needsBind: return "needs_bind"
        case .bound: return "bound"
        }
    }

    var spokenFace: String {
        switch self {
        case .none:
            return "nenhuma área registrada"
        case .auto:
            return "uma área registrada, ligação automática"
        case .needsBind(let n):
            return "escolher área, \(n) áreas registradas"
        case .bound(let name):
            return "área \(name)"
        }
    }

    var needsChooser: Bool {
        if case .needsBind = self { return true }
        return false
    }
}

// MARK: - Judgment

/// Pure area-bind policy — 0/1/N · face · pack · rank for chooser.
enum AutonomosAreaBindJudgment {

    static func registeredAreas(_ areas: [AtlasAutonomosArea]) -> [AtlasAutonomosArea] {
        areas.filter(\.registered)
    }

    /// WAVE-030 law: 1 registered → that id; defaultArea match when multi; else nil.
    static func autoBindID(
        areas: [AtlasAutonomosArea],
        defaultArea: String? = nil
    ) -> String? {
        AutonomosRunControlJudgment.bindAreaID(areas: areas, defaultArea: defaultArea)
    }

    static func face(
        areas: [AtlasAutonomosArea],
        selectedAreaID: String?,
        defaultArea: String? = nil
    ) -> AutonomosAreaBindFace {
        if let selectedAreaID,
           let area = areas.first(where: { $0.id == selectedAreaID }) {
            return .bound(area.areaName.isEmpty ? area.id : area.areaName)
        }
        let registered = registeredAreas(areas)
        if registered.isEmpty { return .none }
        if autoBindID(areas: areas, defaultArea: defaultArea) != nil {
            return .auto
        }
        return .needsBind(registered.count)
    }

    /// Stable chooser order: name, then id.
    static func rankForChooser(_ areas: [AtlasAutonomosArea]) -> [AtlasAutonomosArea] {
        registeredAreas(areas).sorted { lhs, rhs in
            let ln = lhs.areaName.lowercased()
            let rn = rhs.areaName.lowercased()
            if ln != rn { return ln < rn }
            return lhs.id < rhs.id
        }
    }

    static func spokenChooserRow(_ area: AtlasAutonomosArea) -> String {
        var parts = [area.areaName.isEmpty ? area.id : area.areaName]
        if !area.focus.isEmpty {
            parts.append("foco \(area.focus)")
        }
        parts.append("registrada")
        return parts.joined(separator: ", ")
    }

    static func spokenChooser(count: Int) -> String {
        "escolher área dos Autônomos, \(count) área\(count == 1 ? "" : "s") registrada\(count == 1 ? "" : "s")"
    }

    static let spokenChooserHint = "liga a frota a uma área registrada"
    static let spokenClose = "fechar escolha de área"
    static let spokenCloseHint = "volta sem ligar área"
    static let spokenBindRowHint = "liga a frota a esta área"
    static let productCTA = "Escolher área"
    static let productChooserTitle = "Área da frota"
    static let spokenCTA = "escolher área da frota Autônomos"

    static func packFacts(
        areas: [AtlasAutonomosArea],
        selectedAreaID: String?,
        defaultArea: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(areas: areas, selectedAreaID: selectedAreaID, defaultArea: defaultArea)
        let registered = registeredAreas(areas)
        facts.append("area_bind_face: \(face.productWord)")
        facts.append("areas_registered: \(registered.count)")
        facts.append("areas_total: \(areas.count)")
        switch face {
        case .none:
            absences.append("nenhuma área registrada — silenciam órgãos da frota")
        case .auto:
            facts.append("area_bind_policy: auto_single")
        case .needsBind:
            absences.append("multi-área sem seleção — chooser necessário")
        case .bound(let name):
            facts.append("area_selected_name: \(name)")
            if let id = selectedAreaID {
                facts.append("area_selected_id: \(id)")
            }
        }
        return (facts, absences)
    }
}
// MARK: - Evolution timeline judgment (WAVE-034)

enum AutonomosEvolutionFace: Equatable {
    case unbound
    case empty
    case items(Int)

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .empty: return "quiet"
        case .items: return "delivered"
        }
    }

    var spokenFace: String {
        switch self {
        case .unbound: return "área da frota não ligada"
        case .empty: return "sem entregas publicadas"
        case .items(let n):
            return n == 1 ? "1 entrega publicada" : "\(n) entregas publicadas"
        }
    }

    var heroSub: String {
        switch self {
        case .unbound:
            return "Sem área registrada selecionada — evolução não inventa marcos."
        case .empty:
            return "Nenhum ciclo merge-proved neste recorte. Silêncio honesto."
        case .items:
            return "Só o que o ledger publicou com prova."
        }
    }
}

struct AutonomosEvolutionMarco: Identifiable, Equatable {
    let cycle: AtlasAutonomosCycle
    let mergeProved: Bool

    var id: String { cycle.id }

    var title: String {
        if mergeProved {
            return "Merge comprovado · ciclo \(cycle.cycleIndex)"
        }
        return "Ciclo \(cycle.cycleIndex) · \(cycle.outcome)"
    }

    var meta: String {
        var parts: [String] = [cycle.cycleFinalStatus]
        if mergeProved, let hash = cycle.mergeHash.nonEmpty {
            parts.append(String(hash.prefix(8)))
        }
        if !cycle.recordedAt.isEmpty {
            parts.append(cycle.recordedAt)
        }
        return parts.joined(separator: " · ")
    }
}

enum AutonomosEvolutionJudgment {

    /// Prefer delivered (merge-scoped) then other published cycles without inventing merges.
    static func marcos(
        delivered: AtlasAutonomosDeliveredResponse?,
        cycles: AtlasAutonomosCyclesResponse?
    ) -> [AutonomosEvolutionMarco] {
        var seen = Set<String>()
        var out: [AutonomosEvolutionMarco] = []

        for cycle in delivered?.delivered ?? [] {
            let key = cycle.id
            guard seen.insert(key).inserted else { continue }
            let proved = cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
            out.append(AutonomosEvolutionMarco(cycle: cycle, mergeProved: proved))
        }
        for cycle in cycles?.cycles ?? [] {
            let key = cycle.id
            guard seen.insert(key).inserted else { continue }
            let proved = cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
            // Secondary: history cycles only if not already in delivered.
            out.append(AutonomosEvolutionMarco(cycle: cycle, mergeProved: proved))
        }

        return rank(out)
    }

    /// Merge-proved first, then higher cycleIndex, then recordedAt.
    static func rank(_ items: [AutonomosEvolutionMarco]) -> [AutonomosEvolutionMarco] {
        items.sorted { lhs, rhs in
            if lhs.mergeProved != rhs.mergeProved { return lhs.mergeProved && !rhs.mergeProved }
            if lhs.cycle.cycleIndex != rhs.cycle.cycleIndex {
                return lhs.cycle.cycleIndex > rhs.cycle.cycleIndex
            }
            return lhs.cycle.recordedAt > rhs.cycle.recordedAt
        }
    }

    static func face(
        areaSelected: Bool,
        marcos: [AutonomosEvolutionMarco]
    ) -> AutonomosEvolutionFace {
        if !areaSelected { return .unbound }
        if marcos.isEmpty { return .empty }
        return .items(marcos.count)
    }

    static func mergeProvedCount(_ marcos: [AutonomosEvolutionMarco]) -> Int {
        marcos.filter(\.mergeProved).count
    }

    static func hubEvolutionMeta(marcos: [AutonomosEvolutionMarco], areaSelected: Bool) -> String {
        if !areaSelected { return "área unbound" }
        let n = mergeProvedCount(marcos)
        if n == 0 { return "sem merge-proved" }
        return n == 1 ? "1 entrega" : "\(n) entregas"
    }

    static func packFacts(marcos: [AutonomosEvolutionMarco]) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let proved = mergeProvedCount(marcos)
        facts.append("evolution_marcos: \(marcos.count)")
        facts.append("merge_proved: \(proved)")
        for m in marcos.prefix(5) where m.mergeProved {
            facts.append("entrega: ciclo \(m.cycle.cycleIndex)")
        }
        if marcos.isEmpty {
            absences.append("sem ciclos publicados em delivered/cycles neste recorte")
        }
        return (facts, absences)
    }

    // MARK: Marco spoken (WAVE-104)

    static func spokenMarco(title: String, meta: String) -> String {
        "\(title), \(meta)"
    }

    static func spokenMarcoHint(mergeProved: Bool) -> String {
        mergeProved ? "abre o recibo de auto-construção" : ""
    }

}
// MARK: - Types

/// Exclusive governed-action reason sheet face (WAVE-098).
enum AutonomosReasonFace: Equatable {
    case blocked
    case ready

    var productWord: String {
        switch self {
        case .blocked: return "blocked"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .blocked:
            return "confirmar indisponível"
        case .ready:
            return "pronto para confirmar"
        }
    }
}

// MARK: - Judgment

/// Pure governed reason-sheet grammar — face · canSubmit · spoken · pack.
enum AutonomosReasonJudgment {

    static let productNavigationTitle = "Confirmar ação"
    static let productSectionAction = "Ação governada"
    static let productSectionOperator = "Operador"
    static let productActorPlaceholder = "Quem autoriza"
    static let productReasonPlaceholder = "Motivo auditável"
    static let productConfirm = "Confirmar"
    static let productCancel = "Cancelar"
    static let productEndUnit = "Encerrar de vez"
    static let productEndUnitConfirm = "Encerrar este Autônomo?"
    static let spokenCancel = "cancelar ação governada"
    static let spokenCancelHint = "fecha sem registrar recibo"
    static let spokenActorHint = "nome de quem autoriza a ação governada"
    static let spokenReasonHintRequired = "motivo auditável registrado no ledger"
    static let spokenReasonHintOptional = "motivo auditável opcional no ensaio"

    // MARK: Face / submit

    static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func face(
        actor: String,
        reason: String,
        reasonOptional: Bool
    ) -> AutonomosReasonFace {
        canSubmit(actor: actor, reason: reason, reasonOptional: reasonOptional)
            ? .ready
            : .blocked
    }

    static func canSubmit(
        actor: String,
        reason: String,
        reasonOptional: Bool
    ) -> Bool {
        !trimmed(actor).isEmpty
            && (reasonOptional || !trimmed(reason).isEmpty)
    }

    // MARK: Spoken

    static func spokenSheet(actionTitle: String) -> String {
        "confirmar ação governada, \(actionTitle.lowercased())"
    }

    static func spokenConfirm(
        actionTitle: String,
        actor: String,
        reason: String,
        reasonOptional: Bool
    ) -> String {
        let f = face(actor: actor, reason: reason, reasonOptional: reasonOptional)
        switch f {
        case .ready:
            return "confirmar \(actionTitle.lowercased())"
        case .blocked:
            return "confirmar indisponível, preencha operador e motivo"
        }
    }

    static func productReasonSection(reasonOptional: Bool) -> String {
        reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo"
    }

    static func spokenReasonFieldHint(reasonOptional: Bool) -> String {
        reasonOptional ? spokenReasonHintOptional : spokenReasonHintRequired
    }

    // MARK: Pack

    static func packFacts(
        actionTitle: String,
        actor: String,
        reason: String,
        reasonOptional: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let f = face(actor: actor, reason: reason, reasonOptional: reasonOptional)
        facts.append("reason_face: \(f.productWord)")
        facts.append("reason_action: \(actionTitle)")
        facts.append("reason_optional: \(reasonOptional ? "yes" : "no")")
        if trimmed(actor).isEmpty {
            absences.append("operador autorizador vazio")
        } else {
            facts.append("reason_actor_present: true")
        }
        if trimmed(reason).isEmpty {
            if reasonOptional {
                facts.append("reason_body: optional_empty")
            } else {
                absences.append("motivo auditável vazio")
            }
        } else {
            facts.append("reason_body_present: true")
        }
        return (facts, absences)
    }
}
