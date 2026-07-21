import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: HomeOpsJudgment + HomeAskContext fused

// MARK: - Ops judgment

// MARK: - Types

/// Exclusive Autônomos door face on Home OPERAÇÃO (WAVE-047).
enum HomeOpsAutonomosFace: Equatable {
    case unbound
    case quiet
    case fleetPressure(Int)
    case liveLoop
    case incident
    case awaiting(Int)

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .quiet: return "quiet"
        case .fleetPressure: return "fleet_pressure"
        case .liveLoop: return "live"
        case .incident: return "incident"
        case .awaiting: return "awaiting"
        }
    }

    var spokenMeta: String {
        switch self {
        case .unbound:
            return "Autônomos, abre catálogo de escopos soberanos"
        case .quiet:
            return "Autônomos, quieto"
        case .fleetPressure(let n):
            return n == 1
                ? "Autônomos, 1 agente pede atenção"
                : "Autônomos, \(n) agentes pedem atenção"
        case .liveLoop:
            return "Autônomos, loop ao vivo"
        case .incident:
            return "Autônomos, incidente publicado"
        case .awaiting(let n):
            return n == 1
                ? "Autônomos, pede 1 decisão"
                : "Autônomos, pede \(n) decisões"
        }
    }

    var rowMeta: String? {
        switch self {
        case .unbound, .quiet: return nil
        case .fleetPressure(let n): return n == 1 ? "1 atenção" : "\(n) atenção"
        case .liveLoop: return "ao vivo"
        case .incident: return "incidente"
        case .awaiting(let n): return n == 1 ? "1 decisão" : "\(n) decisões"
        }
    }
}

/// Arena door face — no regression badge on Home.
enum HomeOpsArenaFace: Equatable {
    case available
    case domainUnavailable

    var productWord: String {
        switch self {
        case .available: return "available"
        case .domainUnavailable: return "domain_unavailable"
        }
    }

    @MainActor
    var spoken: String {
        switch self {
        case .available:
            return "Arena, abre medição de regressão"
        case .domainUnavailable:
            return "Arena, \(ArenaModel.domainUnavailableCopy)"
        }
    }
}

// MARK: - Judgment

/// Pure Home OPERAÇÃO attention — Autônomos + Arena door only.
enum HomeOpsJudgment {

    @MainActor
    static func autonomosFace(model: AutonomosModel) -> HomeOpsAutonomosFace {
        // Unbound only before any ops hydrate (no areas + no global organs).
        if model.areas.isEmpty,
           model.backlog == nil,
           model.live == nil,
           model.taskHealth == nil,
           model.fleet == nil {
            return .unbound
        }

        let awaiting = AutonomosDecisionJudgment.decisionCount(from: model.backlog)
        if awaiting > 0 {
            return .awaiting(awaiting)
        }

        if AutonomosTaskHealthJudgment.incidentPresent(model.taskHealth) {
            return .incident
        }

        if model.live?.isRunning == true {
            return .liveLoop
        }

        let fleetFace = AutonomosFleetJudgment.face(from: model.fleet)
        if case .attention(let n) = fleetFace {
            return .fleetPressure(n)
        }

        return .quiet
    }

    static func arenaFace(domainUnavailable: Bool) -> HomeOpsArenaFace {
        domainUnavailable ? .domainUnavailable : .available
    }

    // MARK: Catalog shell (WAVE-184)

    /// Home partida catalog — threads known + workspace names (never invents frota).
    static func packCatalogFacts(
        threadCount: Int,
        workspaceNames: [String]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("home_threads_known: \(threadCount)")
        if workspaceNames.isEmpty {
            absences.append("nenhum workspace listado")
        } else {
            facts.append(
                "home_workspaces: \(workspaceNames.prefix(8).joined(separator: ", "))"
            )
        }
        absences.append("não invente contagens de frota/Arena sem a superfície correspondente")
        return (facts, absences)
    }

    @MainActor
    static func packFacts(session: AtlasSession) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let auto = session.autonomos
        let face = autonomosFace(model: auto)
        facts.append("home_ops_autonomos_face: \(face.productWord)")
        facts.append(face.spokenMeta)

        if auto.areas.isEmpty {
            absences.append("áreas Autônomos não hidratadas na porta Home")
        } else {
            facts.append("autonomos_areas: \(auto.areas.count)")
        }
        if auto.backlog == nil {
            absences.append("backlog de decisões não hidratado na Home — sem inventar awaiting")
        } else {
            facts.append("awaiting_decisions: \(AutonomosDecisionJudgment.decisionCount(from: auto.backlog))")
        }
        if auto.taskHealth == nil {
            absences.append("taskHealth não hidratado na Home")
        } else {
            facts.append(
                "incident_present: \(AutonomosTaskHealthJudgment.incidentPresent(auto.taskHealth))"
            )
        }
        if auto.fleet == nil {
            absences.append("fleet global não hidratado na Home")
        } else {
            facts.append("fleet_face: \(AutonomosFleetJudgment.face(from: auto.fleet).productWord)")
        }

        let arena = arenaFace(domainUnavailable: session.arena.isDomainUnavailable)
        facts.append("home_ops_arena_face: \(arena.productWord)")
        facts.append(arena.spoken)
        // Explicit: no regression invent on Home door.
        absences.append("regressão da Arena não eleva na Home (ordem 2026-07-18)")

        return (facts, absences)
    }

    // MARK: Profile spoken (WAVE-104)

    static let operatorProfileSpoken = "Vitor, operador do Atlas"

    static func spokenProfileLine(label: String, value: String) -> String {
        "\(label), \(value)"
    }

}

// MARK: - Ask context

enum HomeAskContext {
    static let invite = "Escreva ao Atlas"

    static func emptySuggestions(hasWorkspaces: Bool) -> [String] {
        if hasWorkspaces {
            return [
                "O que está vivo agora?",
                "Abre o grafo do atlas-native",
                "Como está a Arena?"
            ]
        }
        return [
            "O que está vivo agora?",
            "Começa uma conversa livre",
            "O que preciso julgar hoje?"
        ]
    }

    @MainActor
    static func facts(session: AtlasSession) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        let threads = session.threads
        let workspaces = session.workspaces

        // WAVE-184: Home catalog shell (threads · workspaces).
        let catalog = HomeOpsJudgment.packCatalogFacts(
            threadCount: threads.count,
            workspaceNames: workspaces.map(\.name)
        )
        facts.append(contentsOf: catalog.facts)
        absences.append(contentsOf: catalog.absences)

        // WAVE-064: live anchors follow LiveNow attention rank (not wire order).
        // WAVE-183/186: packFacts canon (packLiveAnchors deleted).
        let livePack = LiveNowJudgment.packFacts(
            local: TurnPresence.shared.liveSessions,
            remote: session.remoteLiveSessions,
            limit: 5
        )
        facts.append(contentsOf: livePack.facts)
        anchors.append(contentsOf: livePack.anchors)
        absences.append(contentsOf: livePack.absences)

        // WAVE-047: ops door attention only from published Autônomos/Arena signals.
        let ops = HomeOpsJudgment.packFacts(session: session)
        facts.append(contentsOf: ops.facts)
        absences.append(contentsOf: ops.absences)

        // WAVE-084: empty editorial face for Home partida (catalog honesty).
        let empty = ConversationEmptyJudgment.packFacts(
            prompt: invite,
            suggestions: emptySuggestions(hasWorkspaces: !workspaces.isEmpty),
            isHomePartida: true,
            hasWorkspaces: !workspaces.isEmpty
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        // WAVE-158: can_do matrix — never bare readChat hardcode; no stop invent.
        let liveCount = LiveNowJudgment.rank(
            local: TurnPresence.shared.liveSessions,
            remote: session.remoteLiveSessions
        ).count
        let autonomosFace = HomeOpsJudgment.autonomosFace(model: session.autonomos)
        let partida = PartidaCanDoJudgment.home(
            autonomosFace: autonomosFace,
            liveCount: liveCount
        )
        absences.append(contentsOf: partida.absences)

        // WAVE-166: ops failure organ when home load failed empty.
        if threads.isEmpty, case .failed = session.phase {
            let failPack = AtlasOpsFailureJudgment.packFacts(
                mode: .network(
                    kind: session.failureKind,
                    hasToken: session.hasToken,
                    host: session.host
                )
            )
            facts.append(contentsOf: failPack.facts)
            absences.append(contentsOf: failPack.absences)
        }

        // WAVE-170: workspace picker face (catalog doors from Home).
        let pickerPack = WorkspacePickerJudgment.packFacts(
            phase: session.phase,
            repoCount: workspaces.count,
            query: "",
            showsNoRepo: workspaces.isEmpty
        )
        facts.append(contentsOf: pickerPack.facts)
        absences.append(contentsOf: pickerPack.absences)

        return AgenticOccasionPack(
            surface: "home",
            subject: "partida do operador",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: partida.canDo
        ).render()
    }
}

// MARK: - Partida can-do

// MARK: - Types

/// WAVE-158: one can_do law for partida doors (Home · Workspace · Radar).
/// Never invents stop/steer/write — those live on conversation / Autônomos faces.
enum PartidaCanDoJudgment {

    struct Result: Equatable {
        let canDo: AgenticOccasionPack.CanDo
        let absences: [String]
    }

    // MARK: Home

    /// Home doors are navigation only. Live/stop/escolher only on open thread.
    static func home(
        autonomosFace: HomeOpsAutonomosFace,
        liveCount: Int
    ) -> Result {
        var absences: [String] = []

        switch autonomosFace {
        case .awaiting:
            absences.append(
                "abrir Autônomos para assinar decisões — NL da Home não decide"
            )
        case .incident:
            absences.append(
                "incidente na frota Autônomos — abrir Autônomos; NL Home não controla loop"
            )
        case .liveLoop:
            absences.append(
                "loop Autônomos ao vivo — controle (pause/kill) só no Hub Autônomos"
            )
        case .fleetPressure:
            absences.append(
                "frota pede atenção — abrir Autônomos; Home só navega"
            )
        case .unbound:
            absences.append("Autônomos ainda unbound — catálogo sem área hidratada")
        case .quiet:
            break
        }

        if liveCount > 0 {
            absences.append(
                "sessoes vivas na Home — stop/escolher/steer só na conversa aberta (não invente cta_only_run_stop aqui)"
            )
        }

        // Nav doors (Autônomos/Arena/Código) are face navigation, not run control.
        // Read chat is the honest pack can_do for partida.
        return Result(canDo: .readChat, absences: absences)
    }

    // MARK: Workspace

    static func workspace(scopedLiveCount: Int) -> Result {
        var absences: [String] = []
        if scopedLiveCount > 0 {
            absences.append(
                "live neste workspace — controle do run só na thread aberta"
            )
        }
        absences.append("workspace pack é leitura/navegação — sem stop/steer inventados")
        return Result(canDo: .readChat, absences: absences)
    }

    // MARK: Radar

    /// Heal CTA is on single-repo Code surface, not multi-repo Radar list.
    /// `hasHealFaceCTA` reserved if a local radar heal button is ever published.
    static func radar(
        hasHealFaceCTA: Bool,
        attentionCount: Int
    ) -> Result {
        var absences: [String] = []
        if attentionCount > 0 {
            absences.append(
                "radar com sem-retorno — curar/heal na superfície do repo, não no pack NL do radar"
            )
        }
        if hasHealFaceCTA {
            // Face CTA local published on this radar chrome.
            return Result(canDo: .faceCTALocal, absences: absences)
        }
        absences.append(
            "radar partida = leitura/julgamento; CTAs de cura só com face publicada no repo"
        )
        return Result(canDo: .readChat, absences: absences)
    }

    // MARK: Search

    /// Search door = read/nav. Opening a thread is navigation, never run control.
    static func search(
        liveInList: Int,
        isOffline: Bool,
        isLoading: Bool
    ) -> Result {
        var absences: [String] = []
        if isLoading {
            absences.append("busca ainda carregando — pack não inventa threads")
        }
        if isOffline {
            absences.append("busca offline — reconecte; NL não inventa catálogo")
        }
        if liveInList > 0 {
            absences.append(
                "threads vivas no recorte — stop/escolher/steer só na conversa aberta"
            )
        }
        absences.append("abrir thread é navegação da face — NL da busca não para run")
        absences.append("search pack = leitura/julgamento do recorte local na sessão")
        return Result(canDo: .readChat, absences: absences)
    }
}

// MARK: - NightlyProposal

@MainActor
@Observable
final class NightlyProposalController: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NightlyProposalController()

    let nightlyIdentifier = "atlas.nightly"
    let morningIdentifier = "atlas.morning"
    @ObservationIgnored let center = UNUserNotificationCenter.current()
    @ObservationIgnored var openAutonomos: (() -> Void)?
    @ObservationIgnored var immediateNightlyDateKey: String?

    var pendingProposal: ProposalPayload?
    private(set) var mutedUntil: Date?

    /// Casca: silêncio total enquanto mute ativo — sem card, sem placeholder, sem toast.
    var isProposalMuted: Bool { isMuted() }

    private override init() {
        super.init()
        mutedUntil = AtlasSession.nightlyProposalMutedUntil()
    }

    func installAsNotificationDelegate() {
        center.delegate = self
    }

    func registerOpenAutonomos(_ handler: @escaping () -> Void) { openAutonomos = handler }

    /// Recusas ensinam: 3 seguidas → pausa automática de 7 dias.
    /// WAVE-070: threshold owned by NightlyProposalJudgment.
    static var dismissStreakPauseThreshold: Int {
        NightlyProposalJudgment.dismissStreakPauseThreshold
    }

    func dismissProposal() {
        pendingProposal = nil
        let streak = AtlasSession.recordNightlyProposalDismissal()
        if streak >= Self.dismissStreakPauseThreshold {
            muteProposal(days: 7)
            AtlasSession.setNightlyProposalAutoPaused(true)
        }
    }

    func muteProposal(days: Int, now: Date = .init()) {
        let days = max(1, days)
        let until = AtlasSession.muteNightlyProposal(days: days, now: now)
        mutedUntil = until
        pendingProposal = nil
        AtlasSession.setNightlyProposalAutoPaused(false)
        center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
    }

    func unmuteProposal() {
        AtlasSession.clearNightlyProposalMute()
        AtlasSession.setNightlyProposalAutoPaused(false)
        AtlasSession.resetNightlyProposalStreak()
        mutedUntil = nil
        Task { await scheduleForBackground() }
    }

    func accept(_ proposal: ProposalPayload) async {
        let delayMinutes = Int(Date().timeIntervalSince(proposal.proposedAt) / 60)
        AtlasSession.recordNightlyProposalAccept(delayMinutes: delayMinutes)
        await scheduleMorning(after: proposal)
        pendingProposal = nil
    }

    #if DEBUG
    func installDemoIfRequested(arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard arguments.contains("-atlas.nightly.demo") else { return }
        unmuteProposal()
        pendingProposal = ProposalPayload(workspaces: ["atlas-native"])
    }
    #endif

    func isMuted(now: Date = .init()) -> Bool {
        guard let mutedUntil else { return false }
        if mutedUntil > now { return true }
        self.mutedUntil = AtlasSession.clearExpiredNightlyProposalMute(now: now)
        return false
    }

    func spokenMuteStatus(now: Date = .init()) -> String? {
        // WAVE-070: mute spoken from Judgment.
        NightlyProposalJudgment.spokenMuteStatus(
            isMuted: isMuted(now: now),
            mutedUntil: mutedUntil,
            autoPaused: AtlasSession.nightlyProposalAutoPaused(),
            now: now,
            relativePrazo: { until, relativeTo in
                let formatter = RelativeDateTimeFormatter()
                formatter.locale = Locale(identifier: "pt_BR")
                formatter.unitsStyle = .full
                return formatter.localizedString(for: until, relativeTo: relativeTo)
            }
        )
    }

    /// WAVE-070: exclusive organ face for hosts/pack.
    var proposalFace: NightlyProposalFace {
        NightlyProposalJudgment.face(
            hasPending: pendingProposal != nil,
            isMuted: isProposalMuted,
            autoPaused: AtlasSession.nightlyProposalAutoPaused()
        )
    }

    // MARK: - Payload

    struct ProposalPayload: Identifiable, Equatable {
        let id: String
        let workspaces: [String]
        let proposedAt: Date

        init(workspaces: [String], proposedAt: Date = .init()) {
            self.workspaces = workspaces
            self.proposedAt = proposedAt
            self.id = workspaces.joined(separator: "|") + "-\(Int(proposedAt.timeIntervalSince1970))"
        }

        var workspaceText: String { workspaces.joined(separator: ", ") }

        var prefilledReason: String {
            "missão noturna proposta às \(Self.hourMinute(proposedAt)) — foco: \(workspaceText)"
        }

        private static func hourMinute(_ date: Date) -> String {
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
        }
    }

    // MARK: - Notification copy

    enum NotificationCopy {
        static let nightlyTitle = "A frota pode trabalhar esta noite"

        static func nightlyBody(workspaces: [String]) -> String {
            "Hoje você mexeu em \(workspaces.joined(separator: ", ")). "
                + "Quer pôr os Autônomos nisso enquanto descansa?"
        }

        static let morningTitle = "Resumo da missão noturna"
        static let morningBody = "Abra Autônomos para ver o que a frota entregou com prova."
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let route = userInfo["atlas.route"] as? String
        let workspaces = userInfo["atlas.workspaces"] as? [String]
        await MainActor.run {
            NightlyProposalController.shared.handle(route: route, workspaces: workspaces)
        }
    }

    func handle(route: String?, workspaces: [String]?) {
        guard let route else { return }
        if route == "autonomos-nightly" {
            guard !isMuted() else {
                openAutonomos?()
                return
            }
            guard let workspaces, !workspaces.isEmpty else {
                openAutonomos?()
                return
            }
            pendingProposal = ProposalPayload(workspaces: workspaces)
            openAutonomos?()
        } else if route == "autonomos" {
            openAutonomos?()
        }
    }
}
struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group { nightlyContent }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: visibilityToken)
    }

    /// WAVE-070: face drives visibility honesty.
    var proposalFace: NightlyProposalFace { nightly.proposalFace }

    var visibilityToken: String {
        switch proposalFace {
        case .pending:
            return nightly.pendingProposal?.id ?? "pending"
        case .muted, .mutedAuto:
            return "muted"
        case .hidden:
            return "hidden"
        }
    }

    @ViewBuilder
    var nightlyContent: some View {
        if case .pending = proposalFace, let proposal = nightly.pendingProposal {
            NightlyProposalCard(
                proposal: proposal,
                onAccept: { onAccept(proposal) },
                onDismiss: { nightly.dismissProposal() },
                onMute: { nightly.muteProposal(days: $0) }
            )
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        } else if let spoken = nightly.spokenMuteStatus() {
            Color.clear
                .frame(height: 0)
                .accessibilityLabel(spoken)
                .accessibilityValue(proposalFace.productWord)
                .accessibilityAddTraits(.isStaticText)
        }
    }
}
extension NightlyProposalController {
    // MARK: - Background schedule

    func scheduleForBackground(now: Date = .init()) async {
        guard !isMuted(now: now) else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
            return
        }
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4, now: now)
        guard let dayEnd = windows.dayEnd else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier, morningIdentifier])
            return
        }

        let summary = await AtlasSession.rhythm.todaySummary(now: now)
        guard !summary.workspaces.isEmpty else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
            return
        }
        guard await canScheduleNotifications() else { return }

        center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
        let request = UNNotificationRequest(
            identifier: nightlyIdentifier,
            content: nightlyBackgroundContent(workspaces: summary.workspaces),
            trigger: nightlyTrigger(dayEnd: dayEnd, now: now)
        )
        try? await center.add(request)
    }

    func nightlyBackgroundContent(workspaces: [String]) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.nightlyTitle
        content.body = NotificationCopy.nightlyBody(workspaces: workspaces)
        content.sound = .default
        content.userInfo = [
            "atlas.route": "autonomos-nightly",
            "atlas.workspaces": workspaces,
        ]
        return content
    }

    func nightlyTrigger(dayEnd: DateComponents, now: Date) -> UNNotificationTrigger {
        guard var target = Self.date(matching: dayEnd, on: now) else {
            return Self.calendarTrigger(for: now.addingTimeInterval(60))
        }
        target += TimeInterval(AtlasSession.nightlyProposalAdjustmentMinutes() * 60)
        if target <= now {
            let today = Self.dateKey(now)
            if immediateNightlyDateKey != today {
                immediateNightlyDateKey = today
                return Self.calendarTrigger(for: now.addingTimeInterval(60))
            }
            return Self.calendarTrigger(for: Calendar.current.date(byAdding: .day, value: 1, to: target) ?? target)
        }
        return Self.calendarTrigger(for: target)
    }

    func scheduleMorning(after proposal: ProposalPayload) async {
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
        guard let dayStart = windows.dayStart,
              let date = nextDayDate(matching: dayStart, after: proposal.proposedAt),
              await canScheduleNotifications() else { return }

        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.morningTitle
        content.body = NotificationCopy.morningBody
        content.sound = .default
        content.userInfo = ["atlas.route": "autonomos"]

        center.removePendingNotificationRequests(withIdentifiers: [morningIdentifier])
        try? await center.add(UNNotificationRequest(
            identifier: morningIdentifier,
            content: content,
            trigger: Self.calendarTrigger(for: date)
        ))
    }

    func canScheduleNotifications() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }

    func nextDayDate(matching components: DateComponents, after date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: 1, to: date).flatMap { Self.date(matching: components, on: $0) }
    }

    static func date(matching time: DateComponents, on date: Date) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = time.hour
        components.minute = time.minute
        return Calendar.current.date(from: components)
    }

    static func calendarTrigger(for date: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    static func dateKey(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

}

// MARK: - Judgment

// MARK: - Types

/// Exclusive nightly proposal organ face (WAVE-070).
enum NightlyProposalFace: Equatable {
    case pending
    case muted
    case mutedAuto
    case hidden

    var productWord: String {
        switch self {
        case .pending: return "pending"
        case .muted: return "muted"
        case .mutedAuto: return "muted_auto"
        case .hidden: return "hidden"
        }
    }

    var spokenFace: String {
        switch self {
        case .pending:
            return "missão noturna proposta"
        case .muted:
            return "propostas noturnas em pausa"
        case .mutedAuto:
            return "propostas em pausa após recusas"
        case .hidden:
            return "sem proposta noturna"
        }
    }
}

// MARK: - Judgment

/// Pure nightly-proposal grammar — face · spoken · pack.
enum NightlyProposalJudgment {

    static let dismissStreakPauseThreshold = 3
    static let muteDays: [Int] = [1, 3, 7]

    static func face(
        hasPending: Bool,
        isMuted: Bool,
        autoPaused: Bool
    ) -> NightlyProposalFace {
        if isMuted {
            return autoPaused ? .mutedAuto : .muted
        }
        if hasPending { return .pending }
        return .hidden
    }

    static func spokenCardLabel(workspaceText: String) -> String {
        "missão noturna proposta. Hoje você trabalhou em \(workspaceText). "
            + "A frota pode continuar enquanto você descansa."
    }

    static let spokenCardHint = "preparar, descartar em silêncio ou pausar por dias"
    static let spokenAcceptLabel = "preparar missão noturna"
    static let spokenAcceptHint = "abre o ensaio governado da missão noturna"
    static let spokenDismissLabel = "hoje não"
    static let spokenDismissHint = "descarta a proposta em silêncio, sem confirmação"
    static let spokenMuteMenuLabel = "pausar propostas noturnas"
    static let spokenMuteMenuHint =
        "oculta card e notificações por 1, 3 ou 7 dias; propostas ficam em pausa"

    static func spokenMuteOption(days: Int) -> String {
        "pausar por \(days) \(days == 1 ? "dia" : "dias")"
    }

    static let spokenMuteOptionHint =
        "remove a proposta e pausa notificações, sem toast"

    /// Relative mute status for a11y when muted (nil when not muted).
    static func spokenMuteStatus(
        isMuted: Bool,
        mutedUntil: Date?,
        autoPaused: Bool,
        now: Date = .init(),
        relativePrazo: (Date, Date) -> String
    ) -> String? {
        guard isMuted, let until = mutedUntil else { return nil }
        let prazo = relativePrazo(until, now)
        if autoPaused {
            return "propostas em pausa — você recusou as últimas \(dismissStreakPauseThreshold); voltam \(prazo)"
        }
        return "propostas noturnas em pausa até \(prazo)"
    }

    static func packFacts(
        hasPending: Bool,
        isMuted: Bool,
        autoPaused: Bool,
        workspaceText: String?,
        mutedUntil: Date?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(hasPending: hasPending, isMuted: isMuted, autoPaused: autoPaused)
        facts.append("nightly_face: \(face.productWord)")
        switch face {
        case .pending:
            if let workspaceText, !workspaceText.isEmpty {
                facts.append("nightly_workspaces: \(workspaceText)")
            } else {
                absences.append("proposta sem workspaces publicados")
            }
        case .muted, .mutedAuto:
            absences.append("propostas noturnas mutadas")
            if let mutedUntil {
                facts.append("nightly_muted_until_s: \(Int(mutedUntil.timeIntervalSince1970))")
            }
            if autoPaused {
                facts.append("nightly_auto_paused: true")
            }
        case .hidden:
            absences.append("sem proposta noturna neste recorte")
        }
        return (facts, absences)
    }
}

// MARK: - NightlyProposalCard

// MARK: - Host

struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    /// Silêncio: some o card sem toast, sem confirmação, sem fila.
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    /// Hora aprendida do fim do dia — o masthead diz o ritmo real, não "21h" fixo.
    @State var learnedDayEnd: String?

    var body: some View {
        cardA11y
            .task {
                let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
                learnedDayEnd = AutonomosRhythmCopy.hour(windows.dayEnd)
            }
    }
}

// MARK: - Body

extension NightlyProposalCard {
    var cardA11y: some View {
        cardChrome
            // .contain preserva botões Preparar/hoje não; o id do card fica
            // no contentor sem engolir os CTAs (XCUITest + VoiceOver).
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.nightlyProposalCard)
            // WAVE-070: exclusive face when card is visible = pending.
            .accessibilityValue(NightlyProposalFace.pending.productWord)
    }
}

extension NightlyProposalCard {
    var actionRow: some View {
        HStack(spacing: 10) {
            Button("Preparar missão noturna") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onAccept()
            }
            .buttonStyle(AutonomosPrimaryButtonStyle())
            .accessibilityIdentifier(A11yID.nightlyProposalAccept)
            .accessibilityLabel(Self.spokenAcceptLabel())
            .accessibilityHint(Self.spokenAcceptHint())
            dismissButton
            muteMenu
        }
    }
}

extension NightlyProposalCard {
    var cardChrome: some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            copyBlock
            actionRow
        }
        .padding(14)
        .atlasCard(cornerRadius: AtlasTheme.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }
}

extension NightlyProposalCard {
    var masthead: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text(learnedDayEnd.map { "MISSÃO NOTURNA · NO SEU RITMO (~\($0))" }
                ?? "MISSÃO NOTURNA · NO SEU RITMO")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension NightlyProposalCard {
    var copyBlock: some View {
        Group {
            Text("Hoje você trabalhou em \(proposal.workspaceText).")
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            Text("A frota pode continuar enquanto você descansa.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension NightlyProposalCard {
    var dismissButton: some View {
        Button("hoje não") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onDismiss()
        }
        .font(AtlasFont.mono(11, .semibold))
        .foregroundStyle(AtlasTheme.textTertiary)
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.nightlyProposalDismiss)
        .accessibilityLabel(Self.spokenDismissLabel())
        .accessibilityHint(Self.spokenDismissHint())
    }
}

extension NightlyProposalCard {
    var muteMenu: some View {
        Menu("pausar") {
            ForEach(NightlyProposalJudgment.muteDays, id: \.self) { days in
                Button("\(days) dia\(days == 1 ? "" : "s")") {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onMute(days)
                }
                .accessibilityLabel(Self.spokenMuteOption(days: days))
                .accessibilityHint(Self.spokenMuteOptionHint())
            }
        }
        .font(AtlasFont.mono(11, .semibold))
        .foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityIdentifier(A11yID.nightlyProposalMute)
        .accessibilityLabel(Self.spokenMuteMenuLabel())
        .accessibilityHint(Self.spokenMuteMenuHint())
    }
}

extension NightlyProposalCard {
    /// WAVE-070: spoken card/actions from NightlyProposalJudgment.
    static func spokenCardLabel(workspaceText: String) -> String {
        NightlyProposalJudgment.spokenCardLabel(workspaceText: workspaceText)
    }

    static func spokenCardHint() -> String {
        NightlyProposalJudgment.spokenCardHint
    }

    static func spokenAcceptLabel() -> String {
        NightlyProposalJudgment.spokenAcceptLabel
    }

    static func spokenAcceptHint() -> String {
        NightlyProposalJudgment.spokenAcceptHint
    }

    static func spokenDismissLabel() -> String {
        NightlyProposalJudgment.spokenDismissLabel
    }

    static func spokenDismissHint() -> String {
        NightlyProposalJudgment.spokenDismissHint
    }

    static func spokenMuteMenuLabel() -> String {
        NightlyProposalJudgment.spokenMuteMenuLabel
    }

    static func spokenMuteMenuHint() -> String {
        NightlyProposalJudgment.spokenMuteMenuHint
    }

    static func spokenMuteOption(days: Int) -> String {
        NightlyProposalJudgment.spokenMuteOption(days: days)
    }

    static func spokenMuteOptionHint() -> String {
        NightlyProposalJudgment.spokenMuteOptionHint
    }
}
