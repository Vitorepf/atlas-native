import Foundation

public struct AtlasTraceChangeReviewDiffResponse: Decodable, Sendable {
    public let patch: Patch
    public let diff: Diff

    public struct Patch: Decodable, Sendable, Identifiable {
        public let id: String
        public let diffHash: String?
        public let computedHash: String?
        public let hashMatches: Bool?
        public let changedFiles: [String]
        public let createdFiles: [String]
        public let deletedFiles: [String]
        public let riskFlags: [String]
        public var patchID: PatchID { PatchID(id) }
    }

    public struct Diff: Decodable, Sendable {
        public let content: String
        public let source: String
        public let sizeBytes: Int
        public let returnedBytes: Int
        public let truncated: Bool
        public let maxBytes: Int
    }
}

public struct AtlasTraceChangeReviewActionInput: Encodable, Sendable {
    public let action: AtlasTraceChangeReview.Action
    public let actor: String?
    public let note: String?

    public init(action: AtlasTraceChangeReview.Action, actor: String? = nil, note: String? = nil) {
        self.action = action
        self.actor = actor
        self.note = note
    }
}

public struct AtlasTraceChangeReviewActionResponse: Decodable, Sendable {
    public let reviewReceipt: Receipt
    public let changeReview: AtlasTraceChangeReview

    public struct Receipt: Decodable, Sendable, Identifiable {
        public let id: String
        public let action: AtlasTraceChangeReview.Action
        public let statusAfter: String?
        public let decisionAfter: String?
        public let occurredAt: String?
    }
}

public struct AtlasTraceChangeReviewFileActionInput: Encodable, Sendable {
    public let patchId: PatchID
    public let filePath: String
    public let action: AtlasTraceChangeReview.Action
    public let actor: String?
    public let note: String?

    public init(
        patchId: PatchID,
        filePath: String,
        action: AtlasTraceChangeReview.Action,
        actor: String? = nil,
        note: String? = nil
    ) {
        self.patchId = patchId
        self.filePath = filePath
        self.action = action
        self.actor = actor
        self.note = note
    }
}

public struct AtlasTraceChangeReviewFileActionResponse: Decodable, Sendable {
    public let fileReviewReceipt: Receipt
    public let changeReview: AtlasTraceChangeReview

    public struct Receipt: Decodable, Sendable {
        public let action: AtlasTraceChangeReview.Action
        public let filePath: String
        public let patchId: PatchID
        public let occurredAt: String?
    }
}

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
