import Foundation

public struct PreparedInteraction: Sendable {
    public let input: CreateAiInteractionInput
    public let wasPending: Bool
    /// Identificador local da instrução de follow-up que originou este turno.
    /// Nunca é enviado ao servidor; serve somente para reconciliar a outbox
    /// com a fila local após relaunch.
    public let followUpId: String?
}
