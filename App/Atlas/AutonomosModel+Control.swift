import Foundation
import Observation
import AtlasCore

/// Start dry-run — peel de AutonomosModel.
/// Pause/kill/transfer/decide removidos da face v9 (zero call sites).
extension AutonomosModel {
    /// Um recibo `enqueued` não muda a UI para executando. A confirmação vem
    /// exclusivamente do lease relido em `/live` após o comando.
    /// Sem área efetiva (seleção ou única registrada), falha honesta — nunca no-op.
    func startRun(
        mode: AtlasAutonomosStartRunMode,
        operatorActor: String,
        operatorReason: String
    ) async {
        guard let area = runTargetArea else {
            let registered = areas.filter(\.registered).count
            if registered == 0 {
                controlError = "Nenhuma área registrada no servidor para enfileirar a missão."
            } else {
                controlError = "Há várias áreas registradas — o app ainda não escolhe qual usar neste ensaio."
            }
            return
        }
        controlError = nil
        do {
            let input = AtlasAutonomosStartRunInput(
                mode: mode,
                operatorActor: operatorActor,
                operatorReason: operatorReason,
                focus: area.focus
            )
            lastStartRunReceipt = try await client.startAutonomosRun(area: area.id, input: input)
            // Ancora a seleção no alvo real do dry-run para o próximo refresh.
            selectedAreaID = area.id
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
