import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — organs task/transfer/list/hub

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
    static let productCTA = "Transferir missão"
    static let spokenFace = "transferência de missão com recibo"

    static let productReasonTitle = "Transferir missão"
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

    static let spokenEmptyHint = "Abre a folha para definir nome e carta"
    static let emptyBody =
        "Defina um Autônomo com escopo fechado. Por agora o catálogo vive só neste iPhone — some se o app for morto."
    static let emptyFootnote =
        "Create no servidor ainda pendente — sem frota 24/7 inventada."
    static let productEmptyHero = "Nenhum ainda"
    static let productCreateCTA = "Novo Autônomo"
    static let spokenCreateHint = "Cria um Autônomo com nome e carta"
    static let productLearnFromUseKicker = "APRENDER COM O USO"

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

    static func productKickerLine(vestment: AutonomosHubVestment, ageLabel: String) -> String {
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
