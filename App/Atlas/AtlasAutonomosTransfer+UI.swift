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

extension AtlasAutonomosRuntimePlacement {
    /// Qualquer campo publicado pelo lock — ausência não vira placeholder na casca.
    var hasVerifiedPlacement: Bool {
        host?.nonEmpty != nil
            || environment?.nonEmpty != nil
            || workspace?.nonEmpty != nil
            || repository?.nonEmpty != nil
            || branch?.nonEmpty != nil
            || acquiredAt?.nonEmpty != nil
            || leaseTTLSeconds != nil
    }
}
