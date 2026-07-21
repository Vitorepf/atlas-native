import AtlasCore
import Foundation
import Observation

// IDLE-COMPRESS AutonomosModel fused

// WAVE-139 AutonomosModel actions peel

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

