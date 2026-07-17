import Foundation
import Observation
import AtlasCore

/// Motor da área Autônomos. Não conhece Views nem conversa: só projeta o
/// estado real do Atlas Continuous Stewardship Loop para a casca própria 24/7.
/// Load → AutonomosModel+Load.swift · comandos → +Control.swift · decisões → +Decide.swift.
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
}
