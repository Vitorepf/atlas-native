import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: AutonomosModel + Actions* peels fused

// MARK: - AutonomosModel

// WAVE-139 AutonomosModel host state

@MainActor
@Observable
final class AutonomosModel {

    let client: AtlasClient

    var phase: LoadPhase = .loaded
    var areas: [AtlasAutonomosArea] = []
    var selectedAreaID: String?
    var live: AtlasAutonomosLiveResponse?
    var cycles: AtlasAutonomosCyclesResponse?
    var delivered: AtlasAutonomosDeliveredResponse?
    var backlog: AtlasAutonomosBacklogResponse?
    var fleet: AtlasAutonomosFleetResponse?
    var fleetHistory: AtlasAutonomosFleetHistoryResponse?
    var taskHealth: AtlasAutonomosTaskHealthResponse?
    var digest: AtlasAutonomosDigestResponse?
    var lastStartRunReceipt: AtlasAutonomosStartRunResponse?
    var lastTransferReceipt: AtlasAutonomosTransferResponse?
    var lastRevertReceipt: AtlasAutonomosCycleRevertResponse?
    var lastControlReceipt: AtlasAutonomosRunControlResponse?
    var lastDecisionReceipt: AtlasAutonomosOperatorDecisionReceipt?
    var controlError: String?
    var operatorUnits: [AutonomosUnit] = []

    init(client: AtlasClient) {
        self.client = client
    }

    var selectedArea: AtlasAutonomosArea? {
        areas.first { $0.id == selectedAreaID }
    }

    var canControlSelectedArea: Bool {
        selectedArea?.registered == true
    }

    func load() async {
        clearSelectionProjection()
        phase = .loaded
        controlError = nil
        do {
            let response = try await client.listAutonomosAreas()
            areas = response.areas
        } catch {
        }
    }

    /// WAVE-047: light Home OPERAÇÃO hydrate — global fleet/taskHealth only.
    /// No area bind, no invent backlog/live. Failures stay silent (nil).
    func refreshGlobalOpsForHome() async {
        async let fleetRequest = client.autonomosFleet()
        async let healthRequest = client.autonomosTaskHealth()
        fleet = try? await fleetRequest
        taskHealth = try? await healthRequest
        // Keep area list warm without clearing global organs.
        if areas.isEmpty {
            do {
                let response = try await client.listAutonomosAreas()
                areas = response.areas
            } catch {
            }
        }
        AtlasNativeSnapshotWriter.shared.recordAutonomos(self)
    }

    func selectArea(_ id: String) async {
        guard areas.contains(where: { $0.id == id }) else { return }
        selectedAreaID = id
        live = nil
        cycles = nil
        delivered = nil
        backlog = nil
        await refreshSelected()
    }

    func clearSelectionProjection() {
        selectedAreaID = nil
        live = nil
        cycles = nil
        delivered = nil
        backlog = nil
        fleet = nil
        fleetHistory = nil
        taskHealth = nil
        digest = nil
    }

    func refreshSelected() async {
        guard selectedAreaID != nil else {
            await load()
            return
        }
        controlError = nil
        do {
            try await loadSelectedDetails()
            if case .idle = phase { phase = .loaded }
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
// MARK: - AutonomosModelActionsLoad

// MARK: - Load selected / errors
extension AutonomosModel {
    func loadSelectedDetails() async throws {
        guard let area = selectedArea else {
            live = nil; cycles = nil; delivered = nil; backlog = nil; fleet = nil; fleetHistory = nil; taskHealth = nil; digest = nil
            AtlasNativeSnapshotWriter.shared.recordAutonomos(self)
            return
        }
        async let liveRequest = client.autonomosLive(area: area.id, focus: area.focus)
        async let cyclesRequest = client.autonomosCycles(area: area.id, focus: area.focus)
        async let deliveredRequest = client.autonomosDelivered(area: area.id, focus: area.focus)
        async let backlogRequest = client.autonomosBacklog(area: area.id, focus: area.focus)
        async let fleetRequest = client.autonomosFleet()
        async let fleetHistoryRequest = client.autonomosFleetHistory()
        async let taskHealthRequest = client.autonomosTaskHealth()
        async let digestRequest = client.autonomosDigest()
        let (nextLive, nextCycles, nextDelivered, nextBacklog) = try await (liveRequest, cyclesRequest, deliveredRequest, backlogRequest)
        live = nextLive
        cycles = nextCycles
        delivered = nextDelivered
        backlog = nextBacklog
        fleet = try? await fleetRequest
        fleetHistory = try? await fleetHistoryRequest
        taskHealth = try? await taskHealthRequest
        digest = try? await digestRequest
        AtlasNativeSnapshotWriter.shared.recordAutonomos(self)
    }

    static func publicMessage(_ error: Error) -> String {
        if let client = error as? AtlasAutonomosClientError {
            switch client {
            case .missingOperatorActor:
                return "Informe quem autoriza esta ação."
            case .missingOperatorReasonForExecute:
                return "Informe o motivo auditável antes de iniciar uma execução."
            case .missingFindingHash:
                return "Escolha uma evidência ou finding antes de registrar a decisão."
            case .missingRationaleForHighRiskAccept:
                return "Aceites de risco alto exigem uma justificativa auditável."
            case .missingTransferReason:
                return "Informe o motivo auditável antes de transferir a missão."
            case .missingRevertReason:
                return "Informe o motivo auditável antes de reverter um ciclo."
            }
        }
        if let api = error as? AtlasApiError { return api.message }
        if error is DecodingError {
            return "O servidor respondeu num formato que o app não reconhece — contrato divergente; atualize o app."
        }
        if let url = error as? URLError {
            switch url.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Sem conexão — verifique o Wi-Fi ou a VPN do Atlas."
            case .timedOut:
                return "O servidor demorou demais para responder — tente de novo."
            case .cannotConnectToHost, .cannotFindHost:
                return "Não foi possível alcançar o Mac — o atlas-server está de pé?"
            default: break
            }
        }
        return "Não foi possível atualizar o estado do Autônomos agora."
    }
}
// MARK: - AutonomosModelActionsDecide

// MARK: - Decide / digest
extension AutonomosModel {
    func refreshDigest() async {
        do {
            digest = try await client.autonomosDigest()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func decide(
        _ decision: AtlasAutonomosOperatorDecision,
        findingHash: String,
        operatorActor: String,
        rationale: String = "",
        riskLevel: AtlasAutonomosRiskLevel = .medium,
        inboxItemId: String? = nil,
        workOrderId: String? = nil,
        evidencePackHash: String? = nil
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosOperatorDecisionInput(
                operatorActor: operatorActor,
                decision: decision,
                findingHash: findingHash,
                rationale: rationale,
                riskLevel: riskLevel,
                inboxItemId: inboxItemId,
                workOrderId: workOrderId,
                evidencePackHash: evidencePackHash
            )
            lastDecisionReceipt = try await client.decideAutonomosOperatorAction(area: area.id, input: input)
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
// MARK: - AutonomosModelActionsRunControl

// MARK: - Run control / start
extension AutonomosModel {
    func control(
        _ action: AtlasAutonomosRunAction,
        operatorActor: String,
        reason: String
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosRunControlInput(
                action: action,
                operatorActor: operatorActor,
                reason: reason,
                focus: area.focus
            )
            lastControlReceipt = try await client.controlAutonomosRun(area: area.id, input: input)
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func startRun(
        mode: AtlasAutonomosStartRunMode,
        operatorActor: String,
        operatorReason: String
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosStartRunInput(
                mode: mode,
                operatorActor: operatorActor,
                operatorReason: operatorReason,
                focus: area.focus
            )
            lastStartRunReceipt = try await client.startAutonomosRun(area: area.id, input: input)
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
// MARK: - AutonomosModelActionsTransfer

// MARK: - Transfer / revert
extension AutonomosModel {
    func transfer(
        operatorActor: String,
        reason: String
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosTransferInput(
                operatorActor: operatorActor,
                reason: reason,
                focus: area.focus
            )
            lastTransferReceipt = try await client.transferAutonomosMission(area: area.id, input: input)
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func refreshTransferStatus() async {
        guard let area = selectedArea, let handoffId = lastTransferReceipt?.handoff.handoffId else { return }
        do {
            lastTransferReceipt = try await client.autonomosTransferStatus(area: area.id, handoffId: handoffId)
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func revertCycle(
        cycle: String,
        operatorActor: String,
        reason: String
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosCycleRevertInput(
                operatorActor: operatorActor,
                reason: reason,
                focus: area.focus
            )
            lastRevertReceipt = try await client.revertAutonomosCycle(
                area: area.id,
                cycle: cycle,
                input: input
            )
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
// MARK: - AutonomosModelActionsUnits

// MARK: - Operator units
extension AutonomosModel {
    func operatorUnit(id: String) -> AutonomosUnit? {
        operatorUnits.first { $0.id == id }
    }

    @discardableResult
    func createOperatorUnit(name: String, charter: String) -> AutonomosUnit {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCharter = charter.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = AutonomosUnit(
            id: UUID().uuidString,
            name: trimmedName.isEmpty ? "Sem nome" : trimmedName,
            charter: trimmedCharter.isEmpty ? "Escopo ainda sem carta." : trimmedCharter,
            createdAt: Date(),
            paused: true
        )
        operatorUnits.insert(unit, at: 0)
        return unit
    }

    func setOperatorUnitPaused(id: String, paused: Bool) {
        guard let index = operatorUnits.firstIndex(where: { $0.id == id }) else { return }
        operatorUnits[index].paused = paused
    }

    func removeOperatorUnit(id: String) {
        operatorUnits.removeAll { $0.id == id }
    }
}

// MARK: - AutonomosTypes

// MARK: - AutonomosUnit

struct AutonomosUnit: Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var charter: String
    var createdAt: Date
    var paused: Bool

    var ageLabel: String {
        let seconds = max(0, Int(Date().timeIntervalSince(createdAt)))
        if seconds < 60 { return "agora" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86_400 { return "\(seconds / 3600)h" }
        let days = seconds / 86_400
        return days == 1 ? "1 dia" : "\(days) dias"
    }
}
// MARK: - AutonomosDestination

enum AutonomosDestination: Hashable, Identifiable {
    case hub
    case evolution
    case decisions
    case decisionInbox(String)
    case decisionOrder(String)
    case moment(String)
    case incident

    var id: String {
        switch self {
        case .hub: "hub"
        case .evolution: "evolution"
        case .decisions: "decisions"
        case .decisionInbox(let h): "inbox-\(h)"
        case .decisionOrder(let id): "order-\(id)"
        case .moment(let id): "moment-\(id)"
        case .incident: "incident"
        }
    }

    var navTitle: String {
        switch self {
        case .hub: "Autônomo"
        case .evolution: "Evolução"
        case .decisions: "Decisões"
        case .decisionInbox, .decisionOrder: "Decisão"
        case .moment: "Momento"
        case .incident: "Precisa de você"
        }
    }

    /// Voltar hierárquico: profundidade → hub → lista.
    var backTarget: AutonomosDestination? {
        switch self {
        case .hub: nil
        default: .hub
        }
    }
}
// MARK: - AutonomosMapNavLine

struct AutonomosMapNavLine: View {
    let title: String
    let meta: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(AtlasFont.serif(16, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(meta)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                Text("›")
                    .font(AtlasFont.serif(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline.padding(.vertical, 0) }
    }
}
// MARK: - AutonomosRhythmLearningLine

struct AutonomosRhythmLearningLine: View {
    /// Placeholder até o actor devolver as janelas reais — a linha existe
    /// imediatamente (UITest + layout estáveis).
    @State private var windows = AtlasDayRhythm.Windows(dayEnd: nil, dayStart: nil, sampleDays: 0)
    @State private var rhythmSheetShown = false
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        Button {
            rhythmSheetShown = true
        } label: {
            HStack(spacing: 5) {
                Text(AutonomosRhythmCopy.line(windows, paused: nightly.isProposalMuted))
                    .font(AtlasFont.mono(10))
                Image(systemName: "chevron.right")
                    .atlasSans(7, .semibold)
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosRhythmCopy.spokenLine(windows, paused: nightly.isProposalMuted))
        .accessibilityValue(
            AutonomosRhythmJudgment.face(
                windows: windows,
                paused: nightly.isProposalMuted
            ).productWord
        )
        .accessibilityHint("mostra o que o Atlas aprendeu do seu dia")
        .accessibilityIdentifier(A11yID.autonomosRhythmLine)
        .sheet(isPresented: $rhythmSheetShown) {
            AutonomosRhythmSheet(windows: windows)
        }
        .task { windows = await AtlasSession.rhythm.windows(minimumDays: 4) }
    }
}
