import Foundation
import Observation
import AtlasCore

/// Motor da área Autônomos. Não conhece Views nem conversa: só projeta o
/// estado real do Atlas Continuous Stewardship Loop para a casca própria 24/7.
/// Load → AutonomosModel+Load.swift · comandos → +Control.swift.
/// Transfer/decide peels removidos (ciclo 252) — zero call sites na face v9.
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
    /// Estado global da frota; não é associado artificialmente à área selecionada.
    var fleet: AtlasAutonomosFleetResponse?
    var fleetHistory: AtlasAutonomosFleetHistoryResponse?
    /// Saúde global da fila do músculo externo; não é um progresso estimado
    /// nem é atribuída artificialmente à área selecionada.
    var taskHealth: AtlasAutonomosTaskHealthResponse?
    /// Digest global governado do Autônomos; agenda ausente permanece ausente.
    var digest: AtlasAutonomosDigestResponse?
    var lastStartRunReceipt: AtlasAutonomosStartRunResponse?
    var controlError: String?
    /// Catálogo do operador (face Autônomos). Em memória até POST create (§5).
    var operatorUnits: [AutonomosUnit] = []

    init(client: AtlasClient) {
        self.client = client
    }

    var selectedArea: AtlasAutonomosArea? {
        areas.first { $0.id == selectedAreaID }
    }

    /// Área efetiva para dry-run: seleção explícita, ou a única registrada.
    /// Zero registrada / ambígua → nil (startRun fala o erro, sem no-op silencioso).
    var runTargetArea: AtlasAutonomosArea? {
        if let selected = selectedArea { return selected }
        let registered = areas.filter(\.registered)
        return registered.count == 1 ? registered.first : nil
    }

    /// Face Autônomos = catálogo local (instantâneo). Áreas do loop hidratam
    /// em segundo plano sem bloquear nem selecionar backlog (anti-badge mentiroso).
    func load() async {
        clearSelectionProjection()
        phase = .loaded
        controlError = nil
        do {
            let response = try await client.listAutonomosAreas()
            areas = response.areas
        } catch {
            // Catálogo local funciona sem isto; não derruba a superfície.
        }
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
