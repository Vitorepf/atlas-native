import AtlasCore
import Foundation
import Observation

// IDLE-COMPRESS AutonomosModel fused

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
