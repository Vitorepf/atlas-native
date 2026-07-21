import Foundation
import Observation
import AtlasCore

/// Pausar, retomar ou kill — peel de AutonomosModel; transfer/revert → +Transfer.
extension AutonomosModel {
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
}
