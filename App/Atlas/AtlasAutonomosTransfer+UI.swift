import AtlasCore

extension AtlasAutonomosTransferResponse {
    /// Casca só projeta o cartão quando o recibo confirma pedido real — sem transfer = silêncio.
    var shouldDisplayTransferStatus: Bool {
        transferRequested != false && !handoff.handoffId.isEmpty
    }

    /// Handoff ainda em curso — editorial de alvo desconhecido só nesta fase.
    var isHandoffInFlight: Bool {
        !isTargetClaimed
            && handoff.status != "cancelled"
            && handoff.status != "failed"
    }
}
