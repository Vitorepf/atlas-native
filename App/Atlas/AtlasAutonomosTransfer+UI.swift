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

    /// Marcos publicados pelo servidor — ausência não vira tag inventada na casca.
    var transferMilestoneTags: [String] {
        var tags: [String] = []
        if let requested = handoff.requestedAt?.nonEmpty { tags.append("pedido \(requested)") }
        if let released = handoff.sourceReleasedAt?.nonEmpty { tags.append("fonte liberada \(released)") }
        if let enqueued = handoff.successorEnqueuedAt?.nonEmpty { tags.append("sucessor enfileirado \(enqueued)") }
        return tags
    }

    var transferSpokenSummary: String {
        var parts = ["transferência", handoff.status, "foco \(handoff.focus)"]
        if let host = handoff.source.host?.nonEmpty { parts.append("fonte \(host)") }
        if isTargetClaimed, let host = handoff.target.host?.nonEmpty {
            parts.append("alvo \(host)")
        } else if isHandoffInFlight {
            parts.append("alvo ainda desconhecido")
        }
        if !transferMilestoneTags.isEmpty { parts.append(transferMilestoneTags.joined(separator: ", ")) }
        if let note = note?.nonEmpty { parts.append(note) }
        return parts.joined(separator: ", ")
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
