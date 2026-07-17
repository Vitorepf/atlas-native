import Foundation

/// Transport adapter — peel de InteractionRun+Polling.

extension AtlasClient: AtlasInteractionTransport {
    public func createInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse {
        try await createAiInteraction(input)
    }

    public func interactionSnapshot(traceId: TraceID) async throws -> AiTraceResponse {
        try await getAiInteraction(traceId)
    }

    public func findInteraction(clientId: ClientID) async throws -> AiTraceResponse? {
        let response = try await listAiInteractions(clientId: clientId.rawValue, limit: 1)
        return response.traces.first.map(AiTraceResponse.init(trace:))
    }

    public func cancelInteractionJob(_ jobId: String) async {
        _ = try? await cancelAiJob(jobId)
    }
}
