import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — digest/run/fleet

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

    static func productWindowLine(_ digest: AtlasAutonomosDigestResponse) -> String {
        let w = digest.last.window
        return "\(w.hours)h · \(w.kind) · \(w.focus) · \(w.timezone)"
    }

    static func productCountsLine(_ digest: AtlasAutonomosDigestResponse) -> String {
        let c = digest.last.counts
        return "entregas \(c.delivered) · riscos \(c.risks) · decisões \(c.pendingDecisions)"
    }

    static func productScheduleLine(_ digest: AtlasAutonomosDigestResponse) -> String? {
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
        return productCountsLine(digest)
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
        facts.append("digest_window: \(productWindowLine(digest))")
        facts.append("digest_counts: \(productCountsLine(digest))")
        if let schedule = productScheduleLine(digest) {
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

    static func productReceiptLine(
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

    static func productSummaryLine(_ fleet: AtlasAutonomosFleetResponse) -> String {
        let alive = fleet.agents.filter(\.alive).count
        let attention = fleet.agents.filter(needsAttention).count
        var parts = ["ativos \(fleet.activeCount)", "vivos \(alive)"]
        if attention > 0 { parts.append("atenção \(attention)") }
        if !fleet.spendingAccounts.isEmpty {
            parts.append("contas \(fleet.spendingAccounts.count)")
        }
        return parts.joined(separator: " · ")
    }

    static func productAgentMeta(_ agent: AtlasAutonomosFleetAgent) -> String {
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
        "\(agent.label), \(productAgentMeta(agent))"
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
        facts.append(productSummaryLine(fleet))
        for a in rank(fleet.agents).prefix(6) {
            facts.append("agent: \(a.label) · \(productAgentMeta(a))")
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
                Text(AutonomosFleetJudgment.productSummaryLine(fleet))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }

            if agents.isEmpty {
                Text(AutonomosListJudgment.productSnapshotNoAgents)
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
                Text(AutonomosListJudgment.productHistory)
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
                Text(AutonomosFleetJudgment.productAgentMeta(agent))
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

