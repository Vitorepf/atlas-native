import AtlasCore

// Milestone tags — peel de AtlasAutonomosTransfer+UISpoken.

extension AtlasAutonomosTransferResponse {
    /// Marcos publicados pelo servidor — ausência não vira tag inventada na casca.
    var transferMilestoneTags: [String] {
        var tags: [String] = []
        if let requested = handoff.requestedAt?.nonEmpty { tags.append("pedido \(requested)") }
        if let released = handoff.sourceReleasedAt?.nonEmpty { tags.append("fonte liberada \(released)") }
        if let enqueued = handoff.successorEnqueuedAt?.nonEmpty { tags.append("sucessor enfileirado \(enqueued)") }
        return tags
    }
}
