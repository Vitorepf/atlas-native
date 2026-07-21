import Foundation
import AtlasCore

// WAVE-173 density peel — AutonomosModel Load

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
