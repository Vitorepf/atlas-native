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

// MARK: - SelfConstructionReceipt

// MARK: - Receipt

// MARK: - Host

struct SelfConstructionReceipt: Identifiable {
    let cycle: AtlasAutonomosCycle
    let finding: AtlasAutonomosFinding?

    var id: String { cycle.id }

    var hasMergeProof: Bool {
        cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
    }
}

extension SelfConstructionReceipt {
    var title: String {
        if let findingTitle = finding?.title.nonEmpty { return findingTitle }
        if hasMergeProof { return "Entrega comprovada no ledger" }
        return "Ciclo registrado sem merge neste recorte"
    }

    var ruleLabel: String {
        if let ruleId = finding?.ruleId?.nonEmpty, let text = finding?.ruleText?.nonEmpty {
            return "\(ruleId) — \(text)"
        }
        if let ruleId = finding?.ruleId?.nonEmpty { return "\(ruleId) — regra publicada sem texto neste recorte." }
        return "Regra não publicada no recorte deste recibo."
    }
}

extension SelfConstructionReceipt {
    var proofLine: String {
        let integrity = cycle.loopReceiptIntegrity.nonEmpty ?? "integridade não publicada"
        var parts = ["integridade \(integrity)", "ciclo \(cycle.cycleIndex)"]
        if hasMergeProof, let hash = cycle.mergeHash.nonEmpty {
            parts.insert("merge \(String(hash.prefix(8)))", at: 1)
        } else {
            parts.append("merge não publicado")
        }
        return parts.joined(separator: " · ")
    }
}
// MARK: - Body

extension SelfConstructionReceiptSheet {
    func spokenRuleLabel() -> String {
        "regra citada, \(receipt.ruleLabel)"
    }

    func spokenProofLabel() -> String {
        "prova, \(receipt.proofLine)"
    }
}

extension SelfConstructionReceiptSheet {
    func spokenSheetLabel() -> String {
        var parts = ["recibo de auto-construção", "ciclo \(receipt.cycle.cycleIndex)"]
        parts.append(receipt.hasMergeProof ? "merge comprovado no ledger" : "sem merge comprovado")
        return parts.joined(separator: ", ")
    }
}

extension SelfConstructionReceiptSheet {
    func spokenHumanSilenceLabel() -> String {
        "você não foi necessário, entrega sem portão"
    }

    func spokenRevertQueueLabel() -> String {
        "veto na fila, ainda não desfeito"
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlockStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            proofBlockTitle
            proofCopyBlock
        }
    }
}
// MARK: - Body chrome

extension SelfConstructionReceiptSheet {
    var proofBlockTitle: some View {
        Text("Prova")
            .font(AtlasFont.mono(10))
            .tracking(0.9)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlock: some View {
        proofChrome(proofBlockStack)
    }
}

extension SelfConstructionReceiptSheet {
    var receiptSealHeader: some View {
        HStack(spacing: 7) {
            Image(systemName: "checkmark.seal")
                .atlasSans(11, .bold)
                .accessibilityHidden(true)
            Text("RECIBO DE AUTO-CONSTRUÇÃO")
                .font(AtlasFont.mono(11))
                .tracking(1.0)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}

extension SelfConstructionReceiptSheet {
    var canSubmitRevert: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension SelfConstructionReceiptSheet {
    func proofChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenProofLabel())
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofCopyBlock: some View {
        Text(receipt.proofLine)
            .font(AtlasFont.mono(12))
            .foregroundStyle(AtlasTheme.textPrimary)
            .textSelection(.enabled)
            .accessibilityHidden(true)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var revertQueueBanner: some View {
        if revertReceipt != nil {
            Text("na fila · ainda não desfeito")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.domOperacional)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.domOperacional.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.domOperacional.opacity(0.35), lineWidth: 1))
                .transition(reduceMotion ? .identity : .opacity)
                .accessibilityLabel(spokenRevertQueueLabel())
        }
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var ruleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regra citada")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text("“\(receipt.ruleLabel)”")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenRuleLabel())
    }
}

extension SelfConstructionReceiptSheet {
    var receiptShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            receiptBody
        }
        .accessibilityIdentifier(A11yID.selfReceiptSheet)
        .accessibilityLabel(spokenSheetLabel())
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var humanSilenceLine: some View {
        if receipt.hasMergeProof {
            Text("você não foi necessário — entrega sem portão")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenHumanSilenceLabel())
        }
    }
}

extension SelfConstructionReceiptSheet {
    var receiptBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            receiptSealHeader
            receiptTitleBlock
            ruleBlock
            proofBlock
            revertQueueBanner
            vetoSection
            humanSilenceLine
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: revertReceipt != nil)
    }
}
// MARK: - Chrome

extension SelfConstructionReceiptSheet {
    var receiptTitleBlock: some View {
        Text(receipt.title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var vetoSection: some View {
        if canRevert {
            VStack(alignment: .leading, spacing: 10) {
                vetoFields
                if let controlError, !controlError.isEmpty {
                    Text(controlError)
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier(A11yID.autonomosControlError)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(SelfConstructionVetoJudgment.spokenFace)
        }
    }
}

extension SelfConstructionReceiptSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza o veto retroativo"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }
}

extension SelfConstructionReceiptSheet {
    func spokenVetoSubmitLabel(canSubmit: Bool) -> String {
        canSubmit ? "desfazer com recibo" : "desfazer indisponível, preencha autor e motivo"
    }

    func spokenVetoSubmitHint(canSubmit: Bool) -> String {
        canSubmit
            ? "envia veto retroativo auditável para este ciclo"
            : "informe quem autoriza e o motivo auditável"
    }
}

extension SelfConstructionReceiptSheet {
    var vetoSubmitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRevert(actor, reason)
        } label: {
            vetoSubmitLabel
        }
        .buttonStyle(PressableScale())
        .disabled(!canSubmitRevert)
        .accessibilityIdentifier(A11yID.selfReceiptVeto)
        .accessibilityLabel(spokenVetoSubmitLabel(canSubmit: canSubmitRevert))
        .accessibilityHint(spokenVetoSubmitHint(canSubmit: canSubmitRevert))
    }
}

extension SelfConstructionReceiptSheet {
    var vetoFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("veto retroativo · com recibo")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            vetoTextFields
            vetoSubmitButton
        }
    }
}

extension SelfConstructionReceiptSheet {
    var vetoSubmitLabel: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.uturn.backward")
                .accessibilityHidden(true)
            Text("Desfazer — com recibo")
        }
        .atlasSans(14, .medium)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .foregroundStyle(AtlasTheme.domOperacional)
        .atlasCard(cornerRadius: 13)
    }
}

extension SelfConstructionReceiptSheet {
    var vetoActorField: some View {
        TextField("Quem autoriza", text: $actor)
            .font(.system(.callout))
            .textInputAutocapitalization(.never)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.55)))
            .accessibilityLabel(AutonomosReasonJudgment.actorPlaceholder)
            .accessibilityHint(spokenActorHint())
    }
}

extension SelfConstructionReceiptSheet {
    var vetoReasonField: some View {
        TextField("Motivo auditável", text: $reason, axis: .vertical)
            .font(.system(.callout))
            .lineLimit(2...4)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.55)))
            .accessibilityLabel(AutonomosReasonJudgment.reasonPlaceholder)
            .accessibilityHint(spokenReasonHint())
    }
}

extension SelfConstructionReceiptSheet {
    var vetoTextFields: some View {
        Group {
            vetoActorField
            vetoReasonField
        }
    }
}

// MARK: - Sheet

struct SelfConstructionReceiptSheet: View {
    let receipt: SelfConstructionReceipt
    var canRevert: Bool = false
    var revertReceipt: AtlasAutonomosCycleRevertResponse? = nil
    /// WAVE-033: public control/revert error from model (honesty).
    var controlError: String? = nil
    var onRevert: (String, String) -> Void = { _, _ in }

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        receiptShell
    }
}

// MARK: - Veto judgment

// MARK: - Self-construction retroactive veto (WAVE-033)

/// Pure judgment: when merge-proved receipt may expose veto-with-receipt UI.
enum SelfConstructionVetoJudgment {

    /// Product word for a11y / pack.
    static let productWord = "veto"

    static let spokenFace = "veto retroativo com recibo"

    /// Merge-proved + area can accept control writes.
    static func canRevert(
        receipt: SelfConstructionReceipt,
        canControlSelectedArea: Bool
    ) -> Bool {
        receipt.hasMergeProof && canControlSelectedArea
    }

    /// Path key for `revertAutonomosCycle(cycle:)` — cycleIndex is the
    /// only stable public index on `AtlasAutonomosCycle` (no cycleId DTO).
    static func cycleKey(for cycle: AtlasAutonomosCycle) -> String {
        String(cycle.cycleIndex)
    }

    static func cycleKey(for receipt: SelfConstructionReceipt) -> String {
        cycleKey(for: receipt.cycle)
    }

    /// Silence reasons for pack / empty veto.
    static func absences(
        receipt: SelfConstructionReceipt?,
        canControlSelectedArea: Bool
    ) -> [String] {
        var out: [String] = []
        guard let receipt else {
            out.append("sem recibo de auto-construção merge-proved neste recorte")
            return out
        }
        if !receipt.hasMergeProof {
            out.append("ciclo sem merge comprovado — veto theater proibido")
        }
        if !canControlSelectedArea {
            out.append("área não controlável — selectArea/registered pendente para revertCycle")
        }
        return out
    }

    // MARK: Pack (WAVE-159)

    /// Pack organ for merge-proved self-construction + veto CTA honesty.
    static func packFacts(
        receipt: SelfConstructionReceipt?,
        canControlSelectedArea: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        let absences = SelfConstructionVetoJudgment.absences(
            receipt: receipt,
            canControlSelectedArea: canControlSelectedArea
        )
        guard let receipt else {
            return (facts, absences)
        }
        facts.append("self_construction_face: \(productWord)")
        facts.append("self_construction_merge_proved: \(receipt.hasMergeProof ? "yes" : "no")")
        if !receipt.cycle.mergeHash.isEmpty {
            facts.append("self_construction_merge_hash: \(receipt.cycle.mergeHash)")
        }
        facts.append("self_construction_cycle: \(cycleKey(for: receipt))")
        let can = canRevert(receipt: receipt, canControlSelectedArea: canControlSelectedArea)
        facts.append("can_revert: \(can ? "yes" : "no")")
        if can {
            facts.append("veto_cta: face_only — sheet de recibo (NL não reverte)")
        }
        return (facts, absences)
    }

    /// Latest merge-proved receipt from published delivered cycles (never invent).
    static func latestMergeProved(
        delivered: AtlasAutonomosDeliveredResponse?
    ) -> SelfConstructionReceipt? {
        guard let cycles = delivered?.delivered else { return nil }
        guard let cycle = cycles.first(where: { $0.mergePerformed && !$0.mergeHash.isEmpty }) else {
            return nil
        }
        return SelfConstructionReceipt(cycle: cycle, finding: nil)
    }
}

// MARK: - AutonomosAskContext

// MARK: - Host pack

// MARK: - Host

enum AutonomosAskContext {
    static func productInvite(destination: AutonomosDestination?, vestment: AutonomosHubVestment) -> String {
        if let destination {
            switch destination {
            case .hub:
                break
            case .decisions:
                return "qual decido primeiro?"
            case .decisionInbox, .decisionOrder:
                return "por que esse valor?"
            case .evolution:
                return "resuma isto"
            case .moment:
                return "por que isto?"
            case .incident:
                return "o que faço?"
            }
        }
        if destination == nil {
            return "o que mudou hoje?"
        }
        switch vestment {
        case .awaiting: return "o que preciso decidir?"
        case .live: return "o que ele fez hoje?"
        case .quiet: return "devo retomar?"
        }
    }

    static func emptySuggestions(destination: AutonomosDestination?) -> [String] {
        switch destination {
        case .decisions, .decisionInbox, .decisionOrder:
            return ["o que bloqueia?", "qual risco aceitar?"]
        case .incident:
            return ["o que quebrou?", "devo transferir?"]
        case .evolution, .moment:
            return ["o que mudou hoje?"]
        case .hub:
            return ["devo retomar?", "o que ele fez?"]
        case nil:
            return ["o que mudou hoje?", "qual Autônomo merece atenção?"]
        }
    }

    static func facts(
        unit: AutonomosUnit?,
        destination: AutonomosDestination?,
        backlog: AtlasAutonomosBacklogResponse? = nil,
        controlFace: AutonomosRunControlFace = .unbound,
        canControl: Bool = false,
        live: AtlasAutonomosLiveResponse? = nil,
        lastControlReceipt: AtlasAutonomosRunControlResponse? = nil,
        delivered: AtlasAutonomosDeliveredResponse? = nil,
        cycles: AtlasAutonomosCyclesResponse? = nil,
        lastTransferReceipt: AtlasAutonomosTransferResponse? = nil,
        taskHealth: AtlasAutonomosTaskHealthResponse? = nil,
        areaSelected: Bool = false,
        fleet: AtlasAutonomosFleetResponse? = nil,
        digest: AtlasAutonomosDigestResponse? = nil,
        areas: [AtlasAutonomosArea] = [],
        selectedAreaID: String? = nil,
        /// WAVE-159: merge-proved self-construction (nil → honest absence).
        selfConstructionReceipt: SelfConstructionReceipt? = nil,
        /// WAVE-159: catalog nightly organ (nil → skip; host passes controller snapshot).
        nightlyPending: Bool? = nil,
        nightlyMuted: Bool = false,
        nightlyAutoPaused: Bool = false,
        nightlyWorkspaceText: String? = nil,
        nightlyMutedUntil: Date? = nil,
        /// WAVE-177: day-rhythm windows from async host (nil → honest absence).
        rhythmWindows: AtlasDayRhythm.Windows? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        // WAVE-184: unit focus pack (charter · local catalog · age).
        let unitPack = AutonomosListJudgment.packUnitFocusFacts(unit: unit)
        facts.append(contentsOf: unitPack.facts)
        absences.append(contentsOf: unitPack.absences)
        anchors.append(contentsOf: unitPack.anchors)
        if unit == nil {
            // WAVE-090: catalog list face when no unit focused (empty/list honesty).
            let listPack = AutonomosListJudgment.packFacts(units: [], awaitingUnitIDs: [])
            facts.append(contentsOf: listPack.facts)
            absences.append(contentsOf: listPack.absences)
        }

        let subjects = AutonomosDecisionJudgment.packSubjects(from: backlog)
        let decisionCount = AutonomosDecisionJudgment.decisionCount(from: backlog)

        appendGlobalOrgans(
            controlFace: controlFace,
            canControl: canControl,
            live: live,
            lastControlReceipt: lastControlReceipt,
            lastTransferReceipt: lastTransferReceipt,
            taskHealth: taskHealth,
            areaSelected: areaSelected,
            fleet: fleet,
            digest: digest,
            areas: areas,
            selectedAreaID: selectedAreaID,
            into: &facts,
            absences: &absences,
            anchors: &anchors
        )

        appendDestinationOrgans(
            unit: unit,
            destination: destination,
            backlog: backlog,
            subjects: subjects,
            decisionCount: decisionCount,
            controlFace: controlFace,
            canControl: canControl,
            live: live,
            taskHealth: taskHealth,
            lastControlReceipt: lastControlReceipt,
            lastTransferReceipt: lastTransferReceipt,
            delivered: delivered,
            cycles: cycles,
            areas: areas,
            selectedAreaID: selectedAreaID,
            into: &facts,
            absences: &absences,
            anchors: &anchors
        )

        absences.append("create no servidor ainda pendente (§5)")
        absences.append("catálogo local some se o app for morto — não invente frota 24/7 persistida")

        let canRevert = appendVetoNightlyCanDoOrgans(
            destination: destination,
            controlFace: controlFace,
            canControl: canControl,
            decisionCount: decisionCount,
            hasUnit: unit != nil,
            delivered: delivered,
            selfConstructionReceipt: selfConstructionReceipt,
            nightlyPending: nightlyPending,
            nightlyMuted: nightlyMuted,
            nightlyAutoPaused: nightlyAutoPaused,
            nightlyWorkspaceText: nightlyWorkspaceText,
            nightlyMutedUntil: nightlyMutedUntil,
            rhythmWindows: rhythmWindows,
            into: &facts,
            absences: &absences,
            anchors: &anchors
        )

        let canDoPack = AutonomosCanDoJudgment.packFacts(
            destination: destination,
            controlFace: controlFace,
            canControl: canControl,
            decisionCount: decisionCount,
            hasUnit: unit != nil,
            canRevert: canRevert
        )
        facts.append(contentsOf: canDoPack.facts)
        absences.append(contentsOf: canDoPack.absences)

        let subject: String
        if decisionCount > 0, let first = subjects.first {
            subject = unit.map { "Autônomo · \($0.name) · \(first)" }
                ?? "decisões · \(first)"
        } else {
            subject = unit.map { "Autônomo · \($0.name)" } ?? "catálogo Autônomos"
        }

        return AgenticOccasionPack(
            surface: "autonomos",
            subject: subject,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: canDoPack.canDo
        ).render()
    }
}
// MARK: - Organs · global

extension AutonomosAskContext {
    // MARK: - Global loop · bind · transfer · health · fleet
    static func appendGlobalOrgans(
        controlFace: AutonomosRunControlFace,
        canControl: Bool,
        live: AtlasAutonomosLiveResponse?,
        lastControlReceipt: AtlasAutonomosRunControlResponse?,
        lastTransferReceipt: AtlasAutonomosTransferResponse?,
        taskHealth: AtlasAutonomosTaskHealthResponse?,
        areaSelected: Bool,
        fleet: AtlasAutonomosFleetResponse?,
        digest: AtlasAutonomosDigestResponse?,
        areas: [AtlasAutonomosArea],
        selectedAreaID: String?,
        into facts: inout [String],
        absences: inout [String],
        anchors: inout [String]
    ) {
        let loop = AutonomosRunControlJudgment.packLoopFacts(
            face: controlFace,
            canControl: canControl,
            live: live,
            receipt: lastControlReceipt
        )
        facts.append(contentsOf: loop.facts)
        absences.append(contentsOf: loop.absences)
        anchors.append("loop · \(controlFace.productWord)")

        if !areas.isEmpty || selectedAreaID != nil {
            let bind = AutonomosAreaBindJudgment.packFacts(
                areas: areas,
                selectedAreaID: selectedAreaID
            )
            facts.append(contentsOf: bind.facts)
            absences.append(contentsOf: bind.absences)
        }

        let transfer = AutonomosTransferJudgment.packFacts(
            canTransfer: AutonomosTransferJudgment.canTransfer(canControlSelectedArea: canControl),
            receipt: lastTransferReceipt
        )
        facts.append(contentsOf: transfer.facts)
        absences.append(contentsOf: transfer.absences)

        let health = AutonomosTaskHealthJudgment.packFacts(
            areaSelected: areaSelected,
            health: taskHealth
        )
        facts.append(contentsOf: health.facts)
        absences.append(contentsOf: health.absences)
        if AutonomosTaskHealthJudgment.incidentPresent(taskHealth) {
            anchors.append("incident · present")
        }

        let fleetPack = AutonomosFleetJudgment.packFacts(fleet)
        facts.append(contentsOf: fleetPack.facts)
        absences.append(contentsOf: fleetPack.absences)

        let digestPack = AutonomosDigestJudgment.packFacts(digest)
        facts.append(contentsOf: digestPack.facts)
        absences.append(contentsOf: digestPack.absences)
    }
}
// MARK: - Organs · veto

extension AutonomosAskContext {
    // MARK: - Veto · nightly · can_do prep
    static func appendVetoNightlyCanDoOrgans(
        destination: AutonomosDestination?,
        controlFace: AutonomosRunControlFace,
        canControl: Bool,
        decisionCount: Int,
        hasUnit: Bool,
        delivered: AtlasAutonomosDeliveredResponse?,
        selfConstructionReceipt: SelfConstructionReceipt?,
        nightlyPending: Bool?,
        nightlyMuted: Bool,
        nightlyAutoPaused: Bool,
        nightlyWorkspaceText: String?,
        nightlyMutedUntil: Date?,
        rhythmWindows: AtlasDayRhythm.Windows? = nil,
        into facts: inout [String],
        absences: inout [String],
        anchors: inout [String]
    ) -> Bool {
        if canControl {
            let reasonPack = AutonomosReasonJudgment.packFacts(
                actionTitle: "controle_loop",
                actor: "",
                reason: "",
                reasonOptional: true
            )
            facts.append(contentsOf: reasonPack.facts)
            absences.append(contentsOf: reasonPack.absences)
            absences.append("reason_sheet: face-only — actor/motivo só no modal governado")
        }

        let mergeReceipt = selfConstructionReceipt
            ?? SelfConstructionVetoJudgment.latestMergeProved(delivered: delivered)
        let vetoPack = SelfConstructionVetoJudgment.packFacts(
            receipt: mergeReceipt,
            canControlSelectedArea: canControl
        )
        facts.append(contentsOf: vetoPack.facts)
        absences.append(contentsOf: vetoPack.absences)
        let canRevert = mergeReceipt.map {
            SelfConstructionVetoJudgment.canRevert(
                receipt: $0,
                canControlSelectedArea: canControl
            )
        } ?? false
        if canRevert {
            anchors.append("veto · merge-proved")
        }

        if destination == nil, let nightlyPending {
            let nightlyPack = NightlyProposalJudgment.packFacts(
                hasPending: nightlyPending,
                isMuted: nightlyMuted,
                autoPaused: nightlyAutoPaused,
                workspaceText: nightlyWorkspaceText,
                mutedUntil: nightlyMutedUntil
            )
            facts.append(contentsOf: nightlyPack.facts)
            absences.append(contentsOf: nightlyPack.absences)
        } else if destination == nil {
            absences.append("nightly organ não snapshot neste turn")
        }

        // WAVE-177: rhythm pack when host awaited windows (catalog only).
        if destination == nil {
            if let rhythmWindows {
                let rhythmPack = AutonomosRhythmJudgment.packFacts(
                    windows: rhythmWindows,
                    paused: nightlyMuted
                )
                facts.append(contentsOf: rhythmPack.facts)
                absences.append(contentsOf: rhythmPack.absences)
            } else {
                absences.append(
                    "ritmo: host não passou windows — pack não inventa sample"
                )
            }
        }
        return canRevert
    }

}
// MARK: - Organs · destination

extension AutonomosAskContext {
    // MARK: - Destination drill
    static func appendDestinationOrgans(
        unit: AutonomosUnit?,
        destination: AutonomosDestination?,
        backlog: AtlasAutonomosBacklogResponse?,
        subjects: [String],
        decisionCount: Int,
        controlFace: AutonomosRunControlFace,
        canControl: Bool,
        live: AtlasAutonomosLiveResponse?,
        taskHealth: AtlasAutonomosTaskHealthResponse?,
        lastControlReceipt: AtlasAutonomosRunControlResponse?,
        lastTransferReceipt: AtlasAutonomosTransferResponse?,
        delivered: AtlasAutonomosDeliveredResponse?,
        cycles: AtlasAutonomosCyclesResponse?,
        areas: [AtlasAutonomosArea],
        selectedAreaID: String?,
        into facts: inout [String],
        absences: inout [String],
        anchors: inout [String]
    ) {
        if let destination {
            facts.append("tela: \(destination.navTitle)")
            anchors.append("dest: \(destination.navTitle)")
            switch destination {
            case .hub:
                facts.append("foco: hub do Autônomo — saúde e atalhos locais")
                // WAVE-179: decision face pack (not hand-roll count only).
                let decisionPack = AutonomosDecisionJudgment.packFacts(
                    backlog: backlog,
                    areaSelected: selectedAreaID != nil || canControl,
                    error: nil
                )
                facts.append(contentsOf: decisionPack.facts)
                absences.append(contentsOf: decisionPack.absences)
                for title in subjects.prefix(5) {
                    anchors.append("decision:\(title)")
                }
                if let unit {
                    let hubPack = AutonomosHubJudgment.packFacts(
                        unitName: unit.name,
                        vestment: AutonomosHubVestment.resolve(
                            backlog: backlog,
                            live: live,
                            incidentPresent: AutonomosTaskHealthJudgment.incidentPresent(taskHealth),
                            unitPaused: unit.paused
                        ),
                        controlFace: controlFace,
                        needsAreaBind: AutonomosAreaBindJudgment.face(
                            areas: areas,
                            selectedAreaID: selectedAreaID
                        ).needsChooser,
                        canTransfer: AutonomosTransferJudgment.canTransfer(
                            canControlSelectedArea: canControl
                        ),
                        hasControlReceipt: lastControlReceipt != nil,
                        hasTransferReceipt: lastTransferReceipt != nil,
                        controlApplied: lastControlReceipt?.applied
                    )
                    facts.append(contentsOf: hubPack.facts)
                    absences.append(contentsOf: hubPack.absences)
                }
            case .decisions, .decisionInbox, .decisionOrder:
                facts.append("foco: decisões")
                // WAVE-179: one law with surface face.
                let decisionPack = AutonomosDecisionJudgment.packFacts(
                    backlog: backlog,
                    areaSelected: true,
                    error: nil
                )
                facts.append(contentsOf: decisionPack.facts)
                absences.append(contentsOf: decisionPack.absences)
                for title in subjects.prefix(5) {
                    anchors.append("decision:\(title)")
                }
            case .evolution:
                facts.append("foco: evolução")
                let evo = AutonomosEvolutionJudgment.packFacts(
                    marcos: AutonomosEvolutionJudgment.marcos(delivered: delivered, cycles: cycles)
                )
                facts.append(contentsOf: evo.facts)
                absences.append(contentsOf: evo.absences)
            case .moment:
                facts.append("foco: digest/momento — janela provider-safe")
            case .incident:
                facts.append("foco: incidente — só sinais reais da face")
            }
        } else {
            facts.append("tela: catálogo do operador")
        }
    }

}

// MARK: - AutonomosDecisionJudgment

// MARK: - Types

/// Published decision the operator can judge — projected only from backlog fields
/// that already require a decision. Never invents inbox rows.
struct AutonomosDecisionItem: Identifiable, Equatable, Hashable {
    enum Kind: Equatable, Hashable {
        case inbox
        case workOrder
    }

    let kind: Kind
    let findingHash: String
    let title: String
    let route: String
    let riskLevel: String
    let priorityScore: Int
    let decisionOptions: [String]
    let inboxItemId: String?
    let workOrderId: String?
    let createdAt: String?

    var id: String {
        switch kind {
        case .inbox: return "inbox:\(findingHash)"
        case .workOrder: return "order:\(workOrderId ?? findingHash)"
        }
    }

    var destination: AutonomosDestination {
        switch kind {
        case .inbox: return .decisionInbox(findingHash)
        case .workOrder: return .decisionOrder(workOrderId ?? findingHash)
        }
    }
}

/// Exclusive decision-surface face (WAVE-026) — one voice for list/detail chrome.
enum AutonomosDecisionFace: Equatable {
    case empty
    case loading
    case items(Int)
    case failed(String)

    var productWord: String {
        switch self {
        case .empty: return "quiet"
        case .loading: return "loading"
        case .items: return "awaiting"
        case .failed: return "failed"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty: return "sem decisões publicadas"
        case .loading: return "carregando decisões"
        case .items(let n):
            return n == 1 ? "1 decisão pedida" : "\(n) decisões pedidas"
        case .failed: return "falha ao carregar decisões"
        }
    }

    var heroTitle: String {
        switch self {
        case .empty: return "Nada pede você"
        case .loading: return "Abrindo decisões…"
        case .items(let n):
            return n == 1 ? "1 decisão" : "\(n) decisões"
        case .failed: return "Decisões fora de alcance"
        }
    }

    var heroSub: String {
        switch self {
        case .empty:
            return "Sem backlog publicado que exija julgamento. Silêncio honesto."
        case .loading:
            return "Só o que o servidor já publicou."
        case .items:
            return "Só o julgamento desbloqueia."
        case .failed(let message):
            return message
        }
    }
}

// MARK: - Judgment

/// Pure decision judgment for Autônomos — rank, faces, item projection.
/// Casca only; never invents counts or rows.
enum AutonomosDecisionJudgment {

    // MARK: Projection

    /// Only rows the server marked as needing operator decision.
    static func items(from backlog: AtlasAutonomosBacklogResponse?) -> [AutonomosDecisionItem] {
        guard let backlog else { return [] }
        let inbox = backlog.inboxItems
            .filter(\.decisionRequired)
            .map { item in
                AutonomosDecisionItem(
                    kind: .inbox,
                    findingHash: item.findingHash,
                    title: item.title,
                    route: item.route,
                    riskLevel: item.riskLevel,
                    priorityScore: item.priorityScore,
                    decisionOptions: item.decisionOptions,
                    inboxItemId: item.findingHash,
                    workOrderId: nil,
                    createdAt: item.createdAt
                )
            }
        let orders = backlog.workOrders
            .filter(\.operatorDecisionRequired)
            .map { order in
                AutonomosDecisionItem(
                    kind: .workOrder,
                    findingHash: order.findingHash,
                    title: order.title,
                    route: order.route,
                    riskLevel: order.riskLevel,
                    priorityScore: order.priorityScore,
                    decisionOptions: [],
                    inboxItemId: nil,
                    workOrderId: order.workOrderId,
                    createdAt: order.createdAt
                )
            }
        return rankItems(inbox + orders)
    }

    static func decisionCount(from backlog: AtlasAutonomosBacklogResponse?) -> Int {
        items(from: backlog).count
    }

    /// Priority-first; stable title as tiebreaker.
    static func rankItems(_ items: [AutonomosDecisionItem]) -> [AutonomosDecisionItem] {
        items.sorted { lhs, rhs in
            if lhs.priorityScore != rhs.priorityScore {
                return lhs.priorityScore > rhs.priorityScore
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    // MARK: Faces

    /// Exclusive face for the decisions surface.
    /// - loading: area selected, no backlog yet, no error
    /// - failed: control/public error while decisions are the focus
    /// - items: published count > 0
    /// - empty: silence (nil backlog without load, or zero decision rows)
    static func face(
        backlog: AtlasAutonomosBacklogResponse?,
        areaSelected: Bool,
        error: String?
    ) -> AutonomosDecisionFace {
        if let error, !error.isEmpty, backlog == nil {
            return .failed(error)
        }
        if areaSelected, backlog == nil, error == nil || error?.isEmpty == true {
            return .loading
        }
        let count = decisionCount(from: backlog)
        if count > 0 { return .items(count) }
        if let error, !error.isEmpty {
            return .failed(error)
        }
        return .empty
    }

    static func item(
        matching destination: AutonomosDestination,
        in backlog: AtlasAutonomosBacklogResponse?
    ) -> AutonomosDecisionItem? {
        let all = items(from: backlog)
        switch destination {
        case .decisionInbox(let hash):
            return all.first { $0.kind == .inbox && $0.findingHash == hash }
        case .decisionOrder(let id):
            return all.first {
                $0.kind == .workOrder && ($0.workOrderId == id || $0.findingHash == id)
            }
        default:
            return nil
        }
    }

    // MARK: List order (catalog)

    /// Judgment order for the operator catalog.
    /// When `awaitingUnitIDs` is non-empty (hydrated signal bound to units),
    /// those rise first; quiet/paused last. Empty set → WAVE-025 live-before-quiet.
    static func rankUnits(
        _ units: [AutonomosUnit],
        awaitingUnitIDs: Set<String> = []
    ) -> [AutonomosUnit] {
        units.enumerated().sorted { lhs, rhs in
            let lAwait = awaitingUnitIDs.contains(lhs.element.id)
            let rAwait = awaitingUnitIDs.contains(rhs.element.id)
            if lAwait != rAwait { return lAwait && !rAwait }
            let lQuiet = lhs.element.paused
            let rQuiet = rhs.element.paused
            if lQuiet != rQuiet { return !lQuiet && rQuiet }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    /// When area backlog is hydrated with decisions but units are local-only
    /// (no wire unit↔area), return empty — never pin “awaiting” on a random unit.
    static func awaitingUnitIDs(
        units: [AutonomosUnit],
        backlog: AtlasAutonomosBacklogResponse?,
        boundUnitID: String?
    ) -> Set<String> {
        guard decisionCount(from: backlog) > 0 else { return [] }
        guard let boundUnitID,
              units.contains(where: { $0.id == boundUnitID }) else {
            return []
        }
        return [boundUnitID]
    }

    // MARK: - Product words / spoken

    static func productPrimaryCTA(count: Int) -> String {
        count == 1 ? "Ver 1 decisão" : "Ver \(count) decisões"
    }

    static func productRowMeta(_ item: AutonomosDecisionItem) -> String {
        let risk = item.riskLevel.trimmingCharacters(in: .whitespacesAndNewlines)
        let route = item.route.trimmingCharacters(in: .whitespacesAndNewlines)
        var parts: [String] = []
        if !risk.isEmpty { parts.append(risk) }
        if !route.isEmpty { parts.append(route) }
        switch item.kind {
        case .inbox: parts.append("inbox")
        case .workOrder: parts.append("ordem")
        }
        return parts.joined(separator: " · ")
    }

    static func spokenItem(_ item: AutonomosDecisionItem) -> String {
        "\(item.title), \(productRowMeta(item))"
    }

    /// Map published option strings + defaults to operator decisions.
    static func allowedDecisions(for item: AutonomosDecisionItem) -> [AtlasAutonomosOperatorDecision] {
        let raw = item.decisionOptions
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        if raw.isEmpty {
            return [.accept, .reject, .deferDecision, .requestChanges]
        }
        var seen = Set<AtlasAutonomosOperatorDecision>()
        var out: [AtlasAutonomosOperatorDecision] = []
        for token in raw {
            let decision: AtlasAutonomosOperatorDecision?
            switch token {
            case "accept", "aceitar", "approve", "aprovar":
                decision = .accept
            case "reject", "rejeitar", "deny":
                decision = .reject
            case "defer", "adiar", "later":
                decision = .deferDecision
            case "request_changes", "request-changes", "changes", "pedir_mudancas", "pedir mudanças":
                decision = .requestChanges
            default:
                decision = AtlasAutonomosOperatorDecision(rawValue: token)
            }
            if let decision, seen.insert(decision).inserted {
                out.append(decision)
            }
        }
        return out.isEmpty ? [.accept, .reject, .deferDecision, .requestChanges] : out
    }

    static func productDecision(_ decision: AtlasAutonomosOperatorDecision) -> String {
        switch decision {
        case .accept: return "Aceitar"
        case .reject: return "Rejeitar"
        case .deferDecision: return "Adiar"
        case .requestChanges: return "Pedir mudanças"
        }
    }

    static func riskLevel(from raw: String) -> AtlasAutonomosRiskLevel {
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "low", "baixo": return .low
        case "high", "alto": return .high
        case "critical", "crítico", "critico": return .critical
        default: return .medium
        }
    }

    /// Mirror of Core high/critical accept rule (internal on Core enum — casca copy).
    static func riskRequiresRationale(_ risk: AtlasAutonomosRiskLevel) -> Bool {
        risk == .high || risk == .critical
    }

    /// Pack subjects = real decision titles (limit).
    static func packSubjects(
        from backlog: AtlasAutonomosBacklogResponse?,
        limit: Int = 5
    ) -> [String] {
        items(from: backlog).prefix(limit).map(\.title)
    }

    // MARK: - Pack face

    /// Surface face + subjects — never invents decision rows.
    static func packFacts(
        backlog: AtlasAutonomosBacklogResponse?,
        areaSelected: Bool,
        error: String? = nil,
        subjectLimit: Int = 5
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(backlog: backlog, areaSelected: areaSelected, error: error)
        facts.append("decision_face: \(face.productWord)")
        let count = decisionCount(from: backlog)
        if count > 0 {
            facts.append("decisoes_publicadas: \(count)")
            for title in packSubjects(from: backlog, limit: subjectLimit) {
                facts.append("decision_subject: \(title)")
            }
        }
        switch face {
        case .loading:
            absences.append("backlog de decisões ainda carregando nesta área")
        case .failed:
            absences.append("falha ao publicar decisões — não invente itens")
        case .empty:
            absences.append("zero itens com decisionRequired / operatorDecisionRequired")
        case .items:
            break
        }
        absences.append("NL não assina decisão — só CTA da face Autônomos")
        return (facts, absences)
    }

    // MARK: - Face chrome spoken

    static func spokenFaceChrome(_ face: AutonomosDecisionFace) -> String {
        "\(face.spokenFace). \(face.heroSub)"
    }

}
