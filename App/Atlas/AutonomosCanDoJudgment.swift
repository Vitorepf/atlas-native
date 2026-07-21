import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: AutonomosJudgments fused

// MARK: - AutonomosCanDoJudgment

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
            absences.append("canControl=false — CTA de loop não é write NL")
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
// MARK: - AutonomosAreaBindJudgment

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
            return "nenhuma área registrada no motor"
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
        "escolher área do loop, \(count) área\(count == 1 ? "" : "s") registrada\(count == 1 ? "" : "s")"
    }

    static let chooserHint = "liga a frota a uma área registrada no motor"
    static let ctaTitle = "Escolher área"
    static let ctaSpoken = "escolher área do loop Autônomos"

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
            absences.append("nenhuma área registered — silenciam órgãos de loop")
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
// MARK: - AutonomosEvolutionJudgment

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
        case .unbound: return "área de loop não ligada"
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

    static func marcoHint(mergeProved: Bool) -> String {
        mergeProved ? "abre o recibo de auto-construção" : ""
    }

}
// MARK: - AutonomosReasonJudgment

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

    static let navigationTitle = "Confirmar ação"
    static let sectionAction = "Ação governada"
    static let sectionOperator = "Operador"
    static let actorPlaceholder = "Quem autoriza"
    static let reasonPlaceholder = "Motivo auditável"
    static let confirmTitle = "Confirmar"
    static let cancelTitle = "Cancelar"
    static let cancelSpoken = "cancelar ação governada"
    static let cancelHint = "fecha sem registrar recibo"
    static let actorHint = "nome de quem autoriza a ação governada"
    static let reasonHintRequired = "motivo auditável registrado no ledger"
    static let reasonHintOptional = "motivo auditável opcional no ensaio"

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

    static func reasonSectionTitle(reasonOptional: Bool) -> String {
        reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo"
    }

    static func reasonFieldHint(reasonOptional: Bool) -> String {
        reasonOptional ? reasonHintOptional : reasonHintRequired
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

// MARK: - AutonomosFleetRunJudgment

// MARK: - AutonomosDigestJudgment

// MARK: - Digest / moment judgment (WAVE-038)

enum AutonomosDigestFace: Equatable {
    case absent
    case quiet
    case attention(pending: Int, risks: Int)
    case delivered(Int)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .quiet: return "quiet"
        case .attention: return "attention"
        case .delivered: return "delivered"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent: return "digest não publicado"
        case .quiet: return "digest quieto nesta janela"
        case .attention(let p, let r):
            return "digest com \(p) decisões e \(r) riscos"
        case .delivered(let n):
            return n == 1 ? "1 entrega no digest" : "\(n) entregas no digest"
        }
    }

    var heroTitle: String {
        switch self {
        case .absent: return "Sem digest"
        case .quiet: return "Janela quieta"
        case .attention: return "Digest pede atenção"
        case .delivered: return "Entregas no digest"
        }
    }
}

enum AutonomosDigestJudgment {

    static func face(from digest: AtlasAutonomosDigestResponse?) -> AutonomosDigestFace {
        guard let digest else { return .absent }
        let c = digest.last.counts
        if c.pendingDecisions > 0 || c.risks > 0 {
            return .attention(pending: c.pendingDecisions, risks: c.risks)
        }
        if c.delivered > 0 {
            return .delivered(c.delivered)
        }
        return .quiet
    }

    static func isPublished(_ digest: AtlasAutonomosDigestResponse?) -> Bool {
        digest != nil
    }

    static func windowLine(_ digest: AtlasAutonomosDigestResponse) -> String {
        let w = digest.last.window
        return "\(w.hours)h · \(w.kind) · \(w.focus) · \(w.timezone)"
    }

    static func countsLine(_ digest: AtlasAutonomosDigestResponse) -> String {
        let c = digest.last.counts
        return "entregas \(c.delivered) · riscos \(c.risks) · decisões \(c.pendingDecisions)"
    }

    static func scheduleLine(_ digest: AtlasAutonomosDigestResponse) -> String? {
        let s = digest.schedule
        if !s.available {
            let reason = s.reason?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return reason.isEmpty ? "agenda indisponível" : "agenda: \(reason)"
        }
        if let next = digest.nextDigestAt?.trimmingCharacters(in: .whitespacesAndNewlines), !next.isEmpty {
            return "próximo digest \(next)"
        }
        return "agenda disponível"
    }

    /// Higher priority first; stable title.
    static func rankPending(
        _ items: [AtlasAutonomosDigestPendingDecision]
    ) -> [AtlasAutonomosDigestPendingDecision] {
        items.sorted { lhs, rhs in
            if lhs.priorityScore != rhs.priorityScore {
                return lhs.priorityScore > rhs.priorityScore
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    /// Severity order: critical > high > medium > low > other.
    static func rankRisks(_ items: [AtlasAutonomosDigestRisk]) -> [AtlasAutonomosDigestRisk] {
        func sev(_ s: String) -> Int {
            switch s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "critical", "critico", "crítico": return 0
            case "high", "alto": return 1
            case "medium", "med", "médio", "medio": return 2
            case "low", "baixo": return 3
            default: return 4
            }
        }
        return items.sorted { lhs, rhs in
            let ls = sev(lhs.severity)
            let rs = sev(rhs.severity)
            if ls != rs { return ls < rs }
            let lt = lhs.title ?? ""
            let rt = rhs.title ?? ""
            return lt.localizedCaseInsensitiveCompare(rt) == .orderedAscending
        }
    }

    static func rankDelivered(
        _ items: [AtlasAutonomosDigestDelivered]
    ) -> [AtlasAutonomosDigestDelivered] {
        items.sorted { lhs, rhs in
            if lhs.mergePerformed != rhs.mergePerformed {
                return lhs.mergePerformed && !rhs.mergePerformed
            }
            return lhs.recordedAt > rhs.recordedAt
        }
    }

    static func hubMeta(from digest: AtlasAutonomosDigestResponse?) -> String? {
        guard let digest else { return nil }
        let c = digest.last.counts
        if c.pendingDecisions + c.risks + c.delivered == 0 {
            return "janela quieta"
        }
        return countsLine(digest)
    }

    static func packFacts(_ digest: AtlasAutonomosDigestResponse?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: digest)
        facts.append("digest_face: \(face.productWord)")
        guard let digest else {
            absences.append("digest não hidratado neste recorte")
            return (facts, absences)
        }
        facts.append("digest_window: \(windowLine(digest))")
        facts.append("digest_counts: \(countsLine(digest))")
        if let schedule = scheduleLine(digest) {
            facts.append("digest_schedule: \(schedule)")
        }
        for d in rankDelivered(digest.last.delivered).prefix(4) {
            facts.append("digest_entrega: ciclo \(d.cycleIndex) · \(d.outcome)")
        }
        for r in rankRisks(digest.last.risks).prefix(4) {
            facts.append("digest_risco: \(r.severity) · \(r.title ?? r.reason ?? r.id)")
        }
        for p in rankPending(digest.last.pendingDecisions).prefix(4) {
            facts.append("digest_decisao: \(p.title) · prio \(p.priorityScore)")
        }
        if digest.last.counts.delivered + digest.last.counts.risks + digest.last.counts.pendingDecisions == 0 {
            absences.append("digest sem itens nesta janela — silêncio honesto")
        }
        return (facts, absences)
    }

    // MARK: Row spoken (WAVE-104)

    static func spokenRow(title: String, meta: String) -> String {
        "\(title), \(meta)"
    }

}

// MARK: - AutonomosRunControlJudgment

// MARK: - Types

/// Exclusive control face for Autônomos loop (WAVE-030) — veto/run organ.
enum AutonomosRunControlFace: Equatable {
    case unbound
    case unregistered
    case running
    case paused
    case killed
    case idle

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .unregistered: return "unregistered"
        case .running: return "running"
        case .paused: return "paused"
        case .killed: return "killed"
        case .idle: return "idle"
        }
    }

    var spokenFace: String {
        switch self {
        case .unbound: return "área de loop não ligada"
        case .unregistered: return "área não registrada no motor"
        case .running: return "loop ao vivo"
        case .paused: return "loop em pausa no servidor"
        case .killed: return "loop encerrado"
        case .idle: return "loop quieto"
        }
    }
}

enum AutonomosRunControlAction: String, Equatable, Identifiable {
    case pause
    case resume
    case kill
    case startExecute
    case startDryRun

    var id: String { rawValue }

    var reasonSheetTitle: String {
        switch self {
        case .pause: return "Pausar o loop"
        case .resume: return "Retomar o loop"
        case .kill: return "Encerrar o loop"
        case .startExecute: return "Iniciar execução"
        case .startDryRun: return "Ensaio (dry-run)"
        }
    }

    var ctaTitle: String {
        switch self {
        case .pause: return "Pausar loop"
        case .resume: return "Retomar loop"
        case .kill: return "Encerrar loop"
        case .startExecute: return "Iniciar loop"
        case .startDryRun: return "Ensaio dry-run"
        }
    }

    var explainer: String {
        switch self {
        case .pause:
            return "Escreve o sinal de pausa no servidor. O loop honra na próxima fronteira segura — não é só opacity da lista local."
        case .resume:
            return "Limpa a pausa e devolve o loop ao ritmo publicado."
        case .kill:
            return "Aciona o kill-switch governado. Exige motivo auditável."
        case .startExecute:
            return "Inicia uma execução real (não ensaio). Motivo e operador obrigatórios."
        case .startDryRun:
            return "Ensaio dry-run: enfileira sem fingir merge. Motivo opcional no ensaio."
        }
    }

    var reasonOptional: Bool {
        switch self {
        case .startDryRun: return true
        default: return false
        }
    }
}

// MARK: - Judgment

enum AutonomosRunControlJudgment {

    /// Auto-bind when exactly one registered area; otherwise nil (honesty multi/zero).
    static func bindAreaID(areas: [AtlasAutonomosArea], defaultArea: String? = nil) -> String? {
        let registered = areas.filter(\.registered)
        if registered.count == 1 { return registered[0].id }
        if let defaultArea,
           let match = registered.first(where: { $0.id == defaultArea }) {
            return match.id
        }
        return nil
    }

    static func face(
        areaSelected: Bool,
        canControl: Bool,
        live: AtlasAutonomosLiveResponse?
    ) -> AutonomosRunControlFace {
        if !areaSelected { return .unbound }
        if !canControl { return .unregistered }
        guard let live else { return .idle }
        if live.isKilled { return .killed }
        if live.isPaused { return .paused }
        if live.isRunning { return .running }
        return .idle
    }

    /// Primary CTA for hub (awaiting decisions still win in HubView before this).
    static func primaryAction(for face: AutonomosRunControlFace) -> AutonomosRunControlAction? {
        switch face {
        case .running: return .pause
        case .paused: return .resume
        case .killed: return .resume // clear path via resume/control if server allows
        case .idle: return .startDryRun
        case .unbound, .unregistered: return nil
        }
    }

    static func secondaryAction(for face: AutonomosRunControlFace) -> AutonomosRunControlAction? {
        switch face {
        case .running: return .kill
        case .idle: return .startExecute
        case .paused: return .kill
        default: return nil
        }
    }

    /// When wire control is available, local unit pause is catalog-only honesty.
    static func demoteLocalPause(canControl: Bool) -> Bool {
        canControl
    }

    static func receiptLine(
        receipt: AtlasAutonomosRunControlResponse?,
        startReceipt: AtlasAutonomosStartRunResponse?,
        error: String?
    ) -> String? {
        if let error, !error.isEmpty { return error }
        if let receipt {
            let verb = receipt.action.rawValue
            let applied = receipt.applied ? "aplicado" : "não aplicado"
            let note = receipt.note.trimmingCharacters(in: .whitespacesAndNewlines)
            if note.isEmpty {
                return "Recibo · \(verb) · \(applied)"
            }
            return "Recibo · \(verb) · \(applied) · \(note)"
        }
        if let start = startReceipt {
            let enq = start.isEnqueued ? "enfileirado" : "não enfileirado"
            return "Start · \(enq)"
        }
        return nil
    }

    static func packLoopFacts(
        face: AutonomosRunControlFace,
        canControl: Bool,
        live: AtlasAutonomosLiveResponse?,
        receipt: AtlasAutonomosRunControlResponse?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("loop_face: \(face.productWord)")
        facts.append("can_control: \(canControl ? "yes" : "no")")
        if let live {
            facts.append("live_phase: \(face.productWord)")
            facts.append("cockpit: \(live.cockpit.status)")
        } else if face == .unbound {
            absences.append("área de loop não ligada — control/start/decide sem selectedArea")
        } else {
            absences.append("live do loop não hidratado")
        }
        if let receipt {
            facts.append("last_control: \(receipt.action.rawValue) · applied=\(receipt.applied)")
        }
        if !canControl, face != .unbound {
            absences.append("área não registrada — canControl=false")
        }
        absences.append("pause da lista local ≠ pause do loop no servidor")
        return (facts, absences)
    }
}

// MARK: - AutonomosFleetJudgment

// MARK: - Fleet judgment (WAVE-037)

enum AutonomosFleetFace: Equatable {
    case absent
    case quiet
    case live(Int)
    case attention(Int)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .quiet: return "quiet"
        case .live: return "live"
        case .attention: return "attention"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent: return "frota não publicada"
        case .quiet: return "frota quieta"
        case .live(let n):
            return n == 1 ? "1 agente vivo" : "\(n) agentes vivos"
        case .attention(let n):
            return n == 1 ? "1 agente pede atenção" : "\(n) agentes pedem atenção"
        }
    }

    var kicker: String {
        switch self {
        case .absent: return "Frota"
        case .quiet: return "Frota quieta"
        case .live: return "Frota viva"
        case .attention: return "Frota pede atenção"
        }
    }
}

enum AutonomosFleetJudgment {

    /// Attention: alive but not authorized, or desired but not alive.
    static func needsAttention(_ agent: AtlasAutonomosFleetAgent) -> Bool {
        if agent.alive && !agent.authorized { return true }
        if agent.desired && !agent.alive { return true }
        return false
    }

    /// Alive first → attention → wire order.
    static func rank(_ agents: [AtlasAutonomosFleetAgent]) -> [AtlasAutonomosFleetAgent] {
        agents.enumerated().sorted { lhs, rhs in
            let la = lhs.element.alive
            let ra = rhs.element.alive
            if la != ra { return la && !ra }
            let lAtt = needsAttention(lhs.element)
            let rAtt = needsAttention(rhs.element)
            if lAtt != rAtt { return lAtt && !rAtt }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(from fleet: AtlasAutonomosFleetResponse?) -> AutonomosFleetFace {
        guard let fleet else { return .absent }
        let agents = fleet.agents
        if agents.isEmpty && fleet.activeCount == 0 { return .quiet }
        let attention = agents.filter(needsAttention).count
        if attention > 0 { return .attention(attention) }
        let alive = agents.filter(\.alive).count
        if alive > 0 { return .live(alive) }
        // Published but none alive — quiet honesty (not invent failure).
        return .quiet
    }

    static func summaryLine(_ fleet: AtlasAutonomosFleetResponse) -> String {
        let alive = fleet.agents.filter(\.alive).count
        let attention = fleet.agents.filter(needsAttention).count
        var parts = ["ativos \(fleet.activeCount)", "vivos \(alive)"]
        if attention > 0 { parts.append("atenção \(attention)") }
        if !fleet.spendingAccounts.isEmpty {
            parts.append("contas \(fleet.spendingAccounts.count)")
        }
        return parts.joined(separator: " · ")
    }

    static func agentMeta(_ agent: AtlasAutonomosFleetAgent) -> String {
        var parts: [String] = [agent.status]
        if agent.alive { parts.append("vivo") }
        if !agent.authorized { parts.append("não autorizado") }
        if agent.desired && !agent.alive { parts.append("desejado") }
        if let up = agent.uptimeSeconds, up > 0 {
            parts.append("up \(up)s")
        }
        return parts.joined(separator: " · ")
    }

    static func spokenAgent(_ agent: AtlasAutonomosFleetAgent) -> String {
        "\(agent.label), \(agentMeta(agent))"
    }

    static func packFacts(_ fleet: AtlasAutonomosFleetResponse?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: fleet)
        facts.append("fleet_face: \(face.productWord)")
        guard let fleet else {
            absences.append("frota global não hidratada neste recorte")
            return (facts, absences)
        }
        facts.append("fleet_master: \(fleet.fleetMaster)")
        facts.append("active_count: \(fleet.activeCount)")
        facts.append("agents: \(fleet.agents.count)")
        facts.append(summaryLine(fleet))
        for a in rank(fleet.agents).prefix(6) {
            facts.append("agent: \(a.label) · \(agentMeta(a))")
        }
        if fleet.agents.isEmpty {
            absences.append("lista de agentes vazia no snapshot publicado")
        }
        absences.append("casca não inventa set/unset de frota — só lê snapshot")
        return (facts, absences)
    }

    /// History tail — last events, silence if empty.
    static func recentEvents(
        _ history: AtlasAutonomosFleetHistoryResponse?,
        limit: Int = 5
    ) -> [AtlasAutonomosFleetHistoryEvent] {
        guard let history else { return [] }
        return Array(history.events.suffix(limit).reversed())
    }
}

// MARK: - Strip chrome

// MARK: - Thin fleet strip on Autônomos catalog (WAVE-037)

/// One domain: published global fleet snapshot — not a monólito map.
struct AutonomosFleetStrip: View {
    let fleet: AtlasAutonomosFleetResponse
    var history: AtlasAutonomosFleetHistoryResponse? = nil

    private var face: AutonomosFleetFace {
        AutonomosFleetJudgment.face(from: fleet)
    }

    private var agents: [AtlasAutonomosFleetAgent] {
        AutonomosFleetJudgment.rank(fleet.agents)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                AutonomosMapChrome.kicker(
                    face.kicker,
                    live: face.productWord == "live" || face.productWord == "attention"
                )
                Spacer(minLength: 0)
                Text(AutonomosFleetJudgment.summaryLine(fleet))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }

            if agents.isEmpty {
                Text("Snapshot publicado sem agentes neste recorte.")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
            } else {
                ForEach(agents.prefix(6)) { agent in
                    agentRow(agent)
                }
                if agents.count > 6 {
                    Text("+\(agents.count - 6) agentes no snapshot")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
            }

            let events = AutonomosFleetJudgment.recentEvents(history, limit: 3)
            if !events.isEmpty {
                Text("Histórico")
                    .font(AtlasFont.mono(10))
                    .tracking(0.8)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 4)
                ForEach(events) { event in
                    Text("\(event.event) · \(event.agentKey) · \(event.at)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 12)
        .background(AtlasTheme.surface.opacity(0.35))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.autonomosFleetMap)
    }

    private func agentRow(_ agent: AtlasAutonomosFleetAgent) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle()
                .fill(agent.alive ? AtlasTheme.accent.opacity(0.9) : AtlasTheme.textTertiary.opacity(0.5))
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.label)
                    .font(AtlasFont.serif(15, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Text(AutonomosFleetJudgment.agentMeta(agent))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(
                        AutonomosFleetJudgment.needsAttention(agent)
                            ? AtlasTheme.domOperacional
                            : AtlasTheme.textTertiary
                    )
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosFleetJudgment.spokenAgent(agent))
    }
}

// MARK: - AutonomosOrgansJudgment

// MARK: - AutonomosTaskHealthJudgment

// MARK: - Task health / incident judgment (WAVE-036)

enum AutonomosTaskHealthFace: Equatable {
    case unbound
    case loading
    case quiet
    case incident(flagCount: Int)
    case pressure

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .loading: return "loading"
        case .quiet: return "quiet"
        case .incident: return "incident"
        case .pressure: return "pressure"
        }
    }

    var spokenFace: String {
        switch self {
        case .unbound: return "saúde da frota não ligada"
        case .loading: return "carregando saúde da frota"
        case .quiet: return "frota quieta, sem incidente publicado"
        case .incident(let n):
            return n == 1 ? "1 sinal de incidente" : "\(n) sinais de incidente"
        case .pressure: return "pressão de fila publicada"
        }
    }

    var heroTitle: String {
        switch self {
        case .unbound: return "Saúde unbound"
        case .loading: return "Lendo saúde…"
        case .quiet: return "Quiet"
        case .incident: return "Precisa de você"
        case .pressure: return "Pressão na fila"
        }
    }

    var heroSub: String {
        switch self {
        case .unbound:
            return "Sem área selecionada — não inventamos incidentes."
        case .loading:
            return "Só o que o servidor publicar em task health."
        case .quiet:
            return "Nenhum incidente. Silêncio honesto."
        case .incident:
            return "Sinais publicados — julgue a ação recomendada."
        case .pressure:
            return "Fila sob pressão; sem flag de incidente explícita."
        }
    }
}

enum AutonomosTaskHealthJudgment {

    static func incidentPresent(_ health: AtlasAutonomosTaskHealthResponse?) -> Bool {
        health?.incidents.present == true
    }

    static func face(
        areaSelected: Bool,
        health: AtlasAutonomosTaskHealthResponse?
    ) -> AutonomosTaskHealthFace {
        if !areaSelected { return .unbound }
        guard let health else { return .loading }
        if health.incidents.present {
            return .incident(flagCount: health.incidents.flags.count)
        }
        let pressure = health.operating.queuePressure
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        if !pressure.isEmpty, pressure != "none", pressure != "low", pressure != "quiet", pressure != "ok" {
            return .pressure
        }
        if health.healthy {
            return .quiet
        }
        // Unhealthy without explicit incident flags — still pressure attention.
        return .pressure
    }

    static func flagLines(_ health: AtlasAutonomosTaskHealthResponse) -> [String] {
        health.incidents.flags
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func tasksSummary(_ health: AtlasAutonomosTaskHealthResponse) -> String {
        let t = health.tasks
        return "claimable \(t.claimable) · claimed \(t.claimed) · blocked \(t.blocked) · completed \(t.completed)"
    }

    static func operatingLine(_ health: AtlasAutonomosTaskHealthResponse) -> String {
        let action = health.operating.recommendedAction
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let pressure = health.operating.queuePressure
            .trimmingCharacters(in: .whitespacesAndNewlines)
        var parts: [String] = []
        if !action.isEmpty { parts.append(action) }
        if !pressure.isEmpty { parts.append("pressão \(pressure)") }
        return parts.isEmpty ? "sem recomendação publicada" : parts.joined(separator: " · ")
    }

    static func hubIncidentMeta(health: AtlasAutonomosTaskHealthResponse?) -> String? {
        guard let health, health.incidents.present else { return nil }
        let n = health.incidents.flags.count
        if n == 0 { return "incidente" }
        return n == 1 ? "1 sinal" : "\(n) sinais"
    }

    static func packFacts(
        areaSelected: Bool,
        health: AtlasAutonomosTaskHealthResponse?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(areaSelected: areaSelected, health: health)
        facts.append("task_health_face: \(face.productWord)")
        guard areaSelected else {
            absences.append("task health sem área selecionada")
            return (facts, absences)
        }
        guard let health else {
            absences.append("task health não hidratado neste recorte")
            return (facts, absences)
        }
        facts.append("healthy: \(health.healthy ? "yes" : "no")")
        facts.append("incidents_present: \(health.incidents.present ? "yes" : "no")")
        facts.append("queue_pressure: \(health.operating.queuePressure)")
        facts.append("recommended_action: \(health.operating.recommendedAction)")
        facts.append("tasks: \(tasksSummary(health))")
        for flag in flagLines(health).prefix(8) {
            facts.append("incident_flag: \(flag)")
        }
        if !health.incidents.present {
            absences.append("sem incidente publicado — não invente alarme")
        }
        return (facts, absences)
    }

    static func spokenSignal(_ flag: String) -> String {
        "sinal \(flag)"
    }

    static func spokenObservedAt(_ observedAt: String) -> String {
        "observado em \(observedAt)"
    }
}
// MARK: - AutonomosTransferJudgment

// MARK: - Mission transfer handoff (WAVE-035)

/// Pure judgment for Autônomos mission transfer — never invents target worker.
enum AutonomosTransferJudgment {

    static let productWord = "transfer"
    static let ctaTitle = "Transferir missão"
    static let spokenFace = "transferência de missão com recibo"

    static let reasonTitle = "Transferir missão"
    static let reasonExplainer =
        "Preserva a mesma missão (área + foco). O target começa desconhecido — a fila escolhe o worker; só o lock dele comprova claimed. Não inicia execução no destino sozinho."

    /// Transfer only when area is selected and registered for control writes.
    static func canTransfer(canControlSelectedArea: Bool) -> Bool {
        canControlSelectedArea
    }

    static func receiptLine(_ receipt: AtlasAutonomosTransferResponse?) -> String? {
        guard let receipt else { return nil }
        if receipt.isTargetClaimed {
            let host = receipt.handoff.target.host?.trimmingCharacters(in: .whitespacesAndNewlines)
            let hostBit = (host?.isEmpty == false) ? " · \(host!)" : ""
            return "Handoff claimed\(hostBit) · \(receipt.handoff.handoffId.prefix(8))"
        }
        if receipt.isAwaitingSourceRelease {
            return "Transfer pedido · aguardando liberação da origem · \(receipt.handoff.handoffId.prefix(8))"
        }
        let note = receipt.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !note.isEmpty {
            return "Transfer · \(receipt.status) · \(note)"
        }
        return "Transfer · \(receipt.status) · \(receipt.handoff.handoffId.prefix(8))"
    }

    static func packFacts(
        canTransfer: Bool,
        receipt: AtlasAutonomosTransferResponse?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("can_transfer: \(canTransfer ? "yes" : "no")")
        if let receipt {
            facts.append("handoff_status: \(receipt.status)")
            facts.append("handoff_id: \(receipt.handoff.handoffId)")
            facts.append("target_status: \(receipt.handoff.target.status)")
            if receipt.isTargetClaimed {
                facts.append("handoff_face: claimed")
            } else if receipt.isAwaitingSourceRelease {
                facts.append("handoff_face: awaiting_source_release")
            }
        } else if canTransfer {
            absences.append("nenhum handoff pedido neste recorte")
        } else {
            absences.append("transfer indisponível — área unbound/unregistered")
        }
        absences.append("casca não escolhe worker target — servidor/fila decide")
        return (facts, absences)
    }
}

// MARK: - AutonomosListJudgment

// MARK: - Types

/// Exclusive Autônomos catalog list face (WAVE-090).
enum AutonomosListFace: Equatable {
    case empty
    case list(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .list(let n): return "list(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "nenhum autônomo ainda"
        case .list(let n):
            let noun = n == 1 ? "autônomo" : "autônomos"
            return "\(n) \(noun)"
        }
    }
}

/// Exclusive catalog row face (WAVE-090).
enum AutonomosListRowFace: Equatable {
    case awaiting
    case live
    case quiet

    var productWord: String {
        switch self {
        case .awaiting: return AutonomosHubVestment.awaiting(1).productWord
        case .live: return AutonomosHubVestment.listFace(unitPaused: false).productWord
        case .quiet: return AutonomosHubVestment.listFace(unitPaused: true).productWord
        }
    }

    var spokenFace: String {
        switch self {
        case .awaiting: return AutonomosHubVestment.awaiting(1).spokenFace
        case .live: return "vivo"
        case .quiet: return AutonomosHubVestment.listFace(unitPaused: true).spokenFace
        }
    }
}

// MARK: - Judgment

/// Pure Autônomos catalog list grammar — list face · row face · rank · spoken · pack.
enum AutonomosListJudgment {

    static let emptyHint = "Abre a folha para definir nome e carta"
    static let emptyBody =
        "Defina um Autônomo com escopo fechado. Por agora o catálogo vive só neste iPhone — some se o app for morto."
    static let emptyFootnote =
        "Create no servidor ainda pendente — sem frota 24/7 inventada."
    static let emptyHero = "Nenhum ainda"
    static let createCTA = "Novo Autônomo"

    // MARK: Face

    static func listFace(unitCount: Int) -> AutonomosListFace {
        unitCount <= 0 ? .empty : .list(unitCount)
    }

    static func rowFace(unitID: String, paused: Bool, awaitingUnitIDs: Set<String>) -> AutonomosListRowFace {
        if awaitingUnitIDs.contains(unitID) { return .awaiting }
        if paused { return .quiet }
        return .live
    }

    static func rowFace(unit: AutonomosUnit, awaitingUnitIDs: Set<String>) -> AutonomosListRowFace {
        rowFace(unitID: unit.id, paused: unit.paused, awaitingUnitIDs: awaitingUnitIDs)
    }

    // MARK: Rank (WAVE-026)

    static func rankUnits(_ units: [AutonomosUnit], awaitingUnitIDs: Set<String>) -> [AutonomosUnit] {
        AutonomosDecisionJudgment.rankUnits(units, awaitingUnitIDs: awaitingUnitIDs)
    }

    // MARK: Spoken

    static func spokenEmpty() -> String {
        "Nenhum Autônomo ainda. Catálogo local neste iPhone; create no servidor pendente."
    }

    static func spokenRow(
        name: String,
        charter: String,
        ageLabel: String,
        rowFace: AutonomosListRowFace
    ) -> String {
        [name, charter, rowFace.spokenFace, ageLabel].joined(separator: ", ")
    }

    static func spokenRow(unit: AutonomosUnit, awaitingUnitIDs: Set<String>) -> String {
        spokenRow(
            name: unit.name,
            charter: unit.charter,
            ageLabel: unit.ageLabel,
            rowFace: rowFace(unit: unit, awaitingUnitIDs: awaitingUnitIDs)
        )
    }

    // MARK: Pack

    static func packFacts(
        units: [AutonomosUnit],
        awaitingUnitIDs: Set<String>
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = listFace(unitCount: units.count)
        facts.append("autonomos_list_face: \(face.productWord)")
        facts.append("autonomos_list_count: \(units.count)")
        facts.append("autonomos_list_awaiting: \(awaitingUnitIDs.count)")
        switch face {
        case .empty:
            absences.append("catálogo Autônomos vazio neste iPhone")
            absences.append("create no servidor ainda pendente (§5)")
        case .list:
            let ranked = rankUnits(units, awaitingUnitIDs: awaitingUnitIDs)
            for unit in ranked.prefix(5) {
                let rf = rowFace(unit: unit, awaitingUnitIDs: awaitingUnitIDs)
                facts.append("autonomos_row: \(unit.name) · \(rf.productWord)")
            }
        }
        return (facts, absences)
    }

    // MARK: Unit focus pack (WAVE-184)

    /// Focused unit charter/catalog/age — never invents server loop from local pause.
    static func packUnitFocusFacts(
        unit: AutonomosUnit?
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []
        guard let unit else {
            absences.append("lista de Autônomos — nenhum aberto")
            return (facts, absences, anchors)
        }
        anchors.append("autonomo: \(unit.name)")
        facts.append("unit_name: \(unit.name)")
        facts.append("unit_charter: \(unit.charter)")
        // WAVE-030: local catalog pause ≠ server loop.
        facts.append(
            unit.paused
                ? "unit_catalog_local: paused_on_iphone"
                : "unit_catalog_local: on_iphone"
        )
        facts.append("unit_age_local: \(unit.ageLabel)")
        if unit.paused {
            absences.append("catalogo_local pausado no iPhone — não invente loop servidor parado")
        }
        return (facts, absences, anchors)
    }
}

// MARK: - AutonomosHubJudgment

// MARK: - Types

/// Exclusive Autônomos hub surface face (WAVE-096).
enum AutonomosHubFace: Equatable {
    case needsBind
    case awaiting(Int)
    case live
    case quiet

    var productWord: String {
        switch self {
        case .needsBind: return "needs_bind"
        case .awaiting: return "awaiting"
        case .live: return "live"
        case .quiet: return "quiet"
        }
    }

    var spokenFace: String {
        switch self {
        case .needsBind:
            return "precisa ligar área"
        case .awaiting(let n):
            return AutonomosHubVestment.awaiting(n).spokenFace
        case .live:
            return AutonomosHubVestment.live.spokenFace
        case .quiet:
            return AutonomosHubVestment.quiet.spokenFace
        }
    }
}

/// Control/transfer receipt presentation tone.
enum AutonomosReceiptTone: Equatable {
    case silent
    case ok
    case error

    var productWord: String {
        switch self {
        case .silent: return "silent"
        case .ok: return "ok"
        case .error: return "error"
        }
    }
}

// MARK: - Judgment

/// Pure hub surface grammar — face · kicker · spoken · receipt tone · pack.
enum AutonomosHubJudgment {

    // MARK: Face

    static func face(
        vestment: AutonomosHubVestment,
        needsAreaBind: Bool
    ) -> AutonomosHubFace {
        if needsAreaBind { return .needsBind }
        switch vestment {
        case .awaiting(let n): return .awaiting(n)
        case .live: return .live
        case .quiet: return .quiet
        }
    }

    // MARK: Kicker / spoken

    static func kickerLine(vestment: AutonomosHubVestment, ageLabel: String) -> String {
        "\(vestment.kicker) · \(ageLabel)"
    }

    static func spokenHub(
        name: String,
        vestment: AutonomosHubVestment,
        controlFace: AutonomosRunControlFace,
        needsAreaBind: Bool
    ) -> String {
        let hub = face(vestment: vestment, needsAreaBind: needsAreaBind)
        var parts = [name, hub.spokenFace, controlFace.spokenFace, vestment.heroTitle]
        if needsAreaBind {
            parts.append("área não ligada")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Receipt tone

    /// Prefer structured applied=false; fallback lexical markers on published line.
    static func receiptTone(
        line: String?,
        controlApplied: Bool? = nil
    ) -> AutonomosReceiptTone {
        guard let line, !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .silent
        }
        if let controlApplied, controlApplied == false {
            return .error
        }
        let lower = line.lowercased()
        let errorMarks = ["não", "erro", "falha", "recus", "negad", "timeout", "indispon"]
        if errorMarks.contains(where: { lower.contains($0) }) {
            return .error
        }
        return .ok
    }

    static func showsControlFaceLine(_ controlFace: AutonomosRunControlFace) -> Bool {
        controlFace != .unbound
    }

    // MARK: Pack

    static func packFacts(
        unitName: String,
        vestment: AutonomosHubVestment,
        controlFace: AutonomosRunControlFace,
        needsAreaBind: Bool,
        canTransfer: Bool,
        hasControlReceipt: Bool,
        hasTransferReceipt: Bool,
        controlApplied: Bool? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let hub = face(vestment: vestment, needsAreaBind: needsAreaBind)
        facts.append("hub_face: \(hub.productWord)")
        facts.append("hub_unit: \(unitName)")
        facts.append("hub_control: \(controlFace.productWord)")
        facts.append("hub_vestment: \(vestment.productWord)")
        if needsAreaBind {
            facts.append("hub_needs_bind: true")
        }
        if canTransfer {
            facts.append("hub_can_transfer: true")
        } else {
            absences.append("transferência não disponível neste hub")
        }
        if hasControlReceipt {
            facts.append("hub_control_receipt: published")
            if let controlApplied {
                facts.append("hub_control_applied: \(controlApplied ? "yes" : "no")")
            }
        } else {
            absences.append("sem recibo de controle no hub")
        }
        if hasTransferReceipt {
            facts.append("hub_transfer_receipt: published")
        } else {
            absences.append("sem recibo de transfer no hub")
        }
        return (facts, absences)
    }

    // MARK: Self-build CTA spoken (WAVE-104)

    static let selfBuildReceiptSpoken =
        "O Atlas melhorou o próprio app, recibo com merge comprovado"

}
