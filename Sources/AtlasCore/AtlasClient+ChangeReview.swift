import Foundation

/// Rotas de change review — peel de AtlasChangeReview.

extension AtlasClient {
    public func getTraceChangeReview(_ traceId: TraceID) async throws -> AtlasTraceChangeReviewResponse {
        return try await get(AtlasRoute.aiInteractionChangeReview(traceId.rawValue))
    }

    public func getTraceChangeReviewDiff(
        traceId: TraceID,
        patchId: PatchID,
        maxBytes: Int? = nil
    ) async throws -> AtlasTraceChangeReviewDiffResponse {
        let query = maxBytes.map { "?max_bytes=\(min(max($0, 1024), 1_048_576))" } ?? ""
        return try await get("\(AtlasRoute.aiInteractionChangeReviewDiff(traceId: traceId.rawValue, patchId: patchId.rawValue))\(query)")
    }

    public func applyTraceChangeReview(
        traceId: TraceID,
        input: AtlasTraceChangeReviewActionInput
    ) async throws -> AtlasTraceChangeReviewActionResponse {
        return try await post(AtlasRoute.aiInteractionChangeReviewAction(traceId.rawValue), body: input)
    }

    public func applyTraceChangeReviewFile(
        traceId: TraceID,
        input: AtlasTraceChangeReviewFileActionInput
    ) async throws -> AtlasTraceChangeReviewFileActionResponse {
        return try await post(AtlasRoute.aiInteractionChangeReviewFileAction(traceId.rawValue), body: input)
    }
}
