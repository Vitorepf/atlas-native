import Foundation
import Observation
import AtlasCore

/// Motor da área Autônomos. Não conhece Views nem conversa: só projeta o
/// estado real do Atlas Continuous Stewardship Loop para a casca própria 24/7.
/// Load → AutonomosModel+Load.swift · comandos → +Control.swift.
/// Face v9: catálogo local + delivered (recibo merge) + taskHealth (snapshot).
@MainActor
@Observable
final class AutonomosModel {

    let client: AtlasClient

    var phase: LoadPhase = .loaded
    var areas: [AtlasAutonomosArea] = []
    var selectedAreaID: String?
    /// Ciclos entregues da área efetiva — banner de merge comprovado.
    var delivered: AtlasAutonomosDeliveredResponse?
    /// Saúde global da fila do músculo externo (widgets / snapshot).
    var taskHealth: AtlasAutonomosTaskHealthResponse?
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
    /// em segundo plano; surfaces globais (taskHealth) alimentam Continuity.
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
        // Uma área registrada: ancora e carrega delivered para o banner.
        if let sole = runTargetArea {
            selectedAreaID = sole.id
        }
        await refreshSelected()
    }

    func clearSelectionProjection() {
        selectedAreaID = nil
        delivered = nil
        taskHealth = nil
    }

    func refreshSelected() async {
        controlError = nil
        do {
            try await loadSelectedDetails()
            if case .idle = phase { phase = .loaded }
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
