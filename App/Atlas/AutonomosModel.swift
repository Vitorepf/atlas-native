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
