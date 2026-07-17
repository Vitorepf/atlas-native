import Foundation
import Observation
import AtlasCore

/// Motor da área Autônomos. Não conhece Views nem conversa: só projeta o
/// estado real do Atlas Continuous Stewardship Loop para a casca própria 24/7.
@MainActor
@Observable
final class AutonomosModel {

    let client: AtlasClient

    var phase: LoadPhase = .idle
    var areas: [AtlasAutonomosArea] = []
    var selectedAreaID: String?
    var live: AtlasAutonomosLiveResponse?
    var cycles: AtlasAutonomosCyclesResponse?
    var delivered: AtlasAutonomosDeliveredResponse?
    var backlog: AtlasAutonomosBacklogResponse?
    /// Estado global da frota; não é associado artificialmente à área selecionada.
    var fleet: AtlasAutonomosFleetResponse?
    var fleetHistory: AtlasAutonomosFleetHistoryResponse?
    /// Saúde global da fila do músculo externo; não é um progresso estimado
    /// nem é atribuída artificialmente à área selecionada.
    var taskHealth: AtlasAutonomosTaskHealthResponse?
    /// Digest global governado do Autônomos; agenda ausente permanece ausente.
    var digest: AtlasAutonomosDigestResponse?
    var lastStartRunReceipt: AtlasAutonomosStartRunResponse?
    var lastTransferReceipt: AtlasAutonomosTransferResponse?
    var lastRevertReceipt: AtlasAutonomosCycleRevertResponse?
    var lastControlReceipt: AtlasAutonomosRunControlResponse?
    var lastDecisionReceipt: AtlasAutonomosOperatorDecisionReceipt?
    var controlError: String?

    init(client: AtlasClient) {
        self.client = client
    }

    var selectedArea: AtlasAutonomosArea? {
        areas.first { $0.id == selectedAreaID }
    }

    /// `live.readOnly` descreve somente a consulta GET. Os comandos possuem
    /// endpoint e recibo próprios; só uma área registrada pode expô-los à UI.
    var canControlSelectedArea: Bool {
        selectedArea?.registered == true
    }

    /// Primeiro carregamento: lista de instâncias e, em seguida, o conjunto
    /// vivo da área selecionada. Nada é marcado 'rodando' até /live confirmar
    /// que o lock do loop está efetivamente retido.
    func load() async {
        phase = .loading
        controlError = nil
        do {
            let response = try await client.listAutonomosAreas()
            areas = response.areas
            let preferred = selectedAreaID ?? response.defaultArea
            selectedAreaID = areas.contains(where: { $0.id == preferred })
                ? preferred
                : areas.first?.id
            try await loadSelectedDetails()
            phase = .loaded
        } catch {
            phase = .failed(Self.publicMessage(error))
        }
    }

    func selectArea(_ id: String) async {
        guard areas.contains(where: { $0.id == id }) else { return }
        selectedAreaID = id
        await refreshSelected()
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

    /// Pausar, retomar ou kill só acontece por ação explícita do operador; o
    /// recibo é relido do servidor para a UI nunca assumir que um signal virou
    /// parada de processo antes da próxima fronteira do loop.
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

    /// Um recibo `enqueued` não muda a UI para executando. A confirmação vem
    /// exclusivamente do lease relido em `/live` após o comando.
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

    /// A transferência pede que a fonte com lease entregue a mesma missão no
    /// próximo limite seguro. O recibo ainda não significa target iniciado;
    /// `target_claimed` só aparece no polling após um worker obter o lock.
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

    /// Enfileira um revert governado para um ciclo já entregue. O endpoint M08
    /// registra o pedido; `gitRevertPerformed == false` continua sendo a verdade
    /// até existir executor/recibo posterior.
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

    func refreshDigest() async {
        do {
            digest = try await client.autonomosDigest()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    /// A decisão é só um recibo governado: mesmo um aceite não aciona owner,
    /// provider ou branch neste caminho. A casca deve mostrá-la como decisão
    /// registrada, nunca como trabalho já executado.
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
