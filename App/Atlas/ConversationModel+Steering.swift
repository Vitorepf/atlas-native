import Foundation
import AtlasCore

@MainActor
extension ConversationModel {
    /// Redireciona uma execução viva no servidor. O recibo aceito só promete
    /// entrega no próximo checkpoint seguro; rejeições também ficam preservadas
    /// para a casca explicar o motivo sem inferir estado.
    func steerInteraction(
        traceId: TraceID,
        instruction: String,
        scope: AtlasInteractionSteerScope
    ) async {
        do {
            let receipt = try await client.steerAiInteraction(
                traceId.rawValue,
                input: .init(instruction: instruction, scope: scope)
            )
            lastSteerReceipt = receipt
            toast = receipt.isAccepted
                ? "Instrução enfileirada para o próximo checkpoint."
                : "Steering recusado: \(receipt.reason?.rawValue ?? "indisponível")."
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }
}
