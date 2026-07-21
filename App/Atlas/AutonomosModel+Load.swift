import Foundation
import Observation
import AtlasCore

extension AutonomosModel {
    /// Surfaces vivas na face v9: delivered (banner merge) + taskHealth (snapshot).
    /// live/cycles/backlog/fleet/digest removidos — zero leitores na casca.
    func loadSelectedDetails() async throws {
        async let taskHealthRequest = client.autonomosTaskHealth()
        if let area = selectedArea ?? runTargetArea {
            async let deliveredRequest = client.autonomosDelivered(area: area.id, focus: area.focus)
            delivered = try? await deliveredRequest
            if selectedAreaID == nil {
                selectedAreaID = area.id
            }
        } else {
            delivered = nil
        }
        taskHealth = try? await taskHealthRequest
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
        // Triagem honesta: contrato divergente não pode se esconder atrás de
        // "fora de alcance" (lição do decode do backlog, 2026-07-17).
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
