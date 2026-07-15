import Foundation

/// Contrato público da revisão de mudança ligada a uma interação. O app nunca
/// recebe o identificador do engineering run: a autorização é sempre o trace
/// que originou a conversa.
public struct AtlasTraceChangeReviewResponse: Decodable, Sendable {
    public let changeReview: AtlasTraceChangeReview
}

public struct AtlasTraceChangeReview: Decodable, Sendable {
    public static let schemaVersion = "atlas.trace_change_review.v1"

    public let schemaVersion: String
    public let state: State
    public let reason: String?
    public let traceId: String
    public let run: Run?
    public let patches: [Patch]
    public let controls: [Control]
    public let testRuns: [TestRun]
    public let review: Review

    public enum State: String, Decodable, Sendable { case available, unavailable }

    public struct Run: Decodable, Sendable {
        public let status: String?
        public let decision: String?
        public let score: Int?
        public let startedAt: String?
        public let finishedAt: String?
    }

    public struct Patch: Decodable, Sendable, Identifiable {
        public let id: String
        public let baseRef: String?
        public let headRef: String?
        public let diffHash: String?
        public let changedFiles: [String]
        public let createdFiles: [String]
        public let deletedFiles: [String]
        public let riskFlags: [String]
        /// Estado canônico atual por arquivo para este artefato imutável. A
        /// ausência preserva compatibilidade com uma API ainda sem C16.
        public let fileReviews: [FileReview]
        public let createdAt: String?
        public let diffURL: String

        private enum CodingKeys: String, CodingKey {
            case id, baseRef, headRef, diffHash, changedFiles, createdFiles, deletedFiles, riskFlags, fileReviews, createdAt
            case diffURL = "diffUrl"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            baseRef = try values.decodeIfPresent(String.self, forKey: .baseRef)
            headRef = try values.decodeIfPresent(String.self, forKey: .headRef)
            diffHash = try values.decodeIfPresent(String.self, forKey: .diffHash)
            changedFiles = try values.decode([String].self, forKey: .changedFiles)
            createdFiles = try values.decode([String].self, forKey: .createdFiles)
            deletedFiles = try values.decode([String].self, forKey: .deletedFiles)
            riskFlags = try values.decode([String].self, forKey: .riskFlags)
            fileReviews = try values.decodeIfPresent([FileReview].self, forKey: .fileReviews) ?? []
            createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
            diffURL = try values.decode(String.self, forKey: .diffURL)
        }

        public func contains(_ filePath: String) -> Bool {
            changedFiles.contains(filePath) || createdFiles.contains(filePath) || deletedFiles.contains(filePath)
        }
    }

    public struct FileReview: Decodable, Sendable, Identifiable {
        public let filePath: String
        public let action: Action
        public let actor: String?
        public let note: String?
        public let decidedAt: String?

        public var id: String { filePath }
    }

    public struct Control: Decodable, Sendable, Identifiable {
        public let id: String
        public let slug: String
        public let status: String
        public let signalSummary: String
        public let durationMs: Int?
        public let createdAt: String?
    }

    public struct TestRun: Decodable, Sendable, Identifiable {
        public let id: String
        public let command: String?
        public let status: String
        public let exitCode: Int?
        public let durationMs: Int?
        public let createdAt: String?
    }

    public struct Review: Decodable, Sendable {
        public let findings: [Finding]
        public let operatorActions: [OperatorAction]
        public let availableActions: [Action]
    }

    public struct Finding: Decodable, Sendable, Identifiable {
        public let id: String
        public let source: String?
        public let severity: String?
        public let status: String?
        public let confidence: Double?
        public let category: String?
        public let title: String?
        public let filePath: String?
        public let startLine: Int?
        public let endLine: Int?
        public let recommendation: String?
        public let detectedAt: String?
    }

    public struct OperatorAction: Decodable, Sendable, Identifiable {
        public let id: String
        public let action: Action
        public let actor: String?
        public let statusBefore: String?
        public let statusAfter: String?
        public let actedAt: String?
    }

    /// A mesma taxonomia governa o aceite global e a decisão do arquivo. O
    /// escopo vem da rota e do recibo, nunca de uma ação local otimista.
    public enum Action: String, Codable, Sendable { case accept, reject }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, state, reason, traceId, run, patches, controls, testRuns, review
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == Self.schemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: values,
                debugDescription: "Unsupported trace change review schema."
            )
        }

        self.schemaVersion = schemaVersion
        self.state = try values.decode(State.self, forKey: .state)
        self.reason = try values.decodeIfPresent(String.self, forKey: .reason)
        self.traceId = try values.decode(String.self, forKey: .traceId)
        self.run = try values.decodeIfPresent(Run.self, forKey: .run)
        self.patches = try values.decode([Patch].self, forKey: .patches)
        self.controls = try values.decode([Control].self, forKey: .controls)
        self.testRuns = try values.decode([TestRun].self, forKey: .testRuns)
        self.review = try values.decode(Review.self, forKey: .review)

        if state == .available && run == nil {
            throw DecodingError.dataCorruptedError(
                forKey: .run,
                in: values,
                debugDescription: "Available review requires its bound run."
            )
        }
        if state == .unavailable && run != nil {
            throw DecodingError.dataCorruptedError(
                forKey: .run,
                in: values,
                debugDescription: "Unavailable review cannot expose a run."
            )
        }
    }
}

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
    public let patchId: String
    public let filePath: String
    public let action: AtlasTraceChangeReview.Action
    public let actor: String?
    public let note: String?

    public init(
        patchId: String,
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
        public let patchId: String
        public let occurredAt: String?
    }
}

extension AtlasClient {
    public func getTraceChangeReview(_ traceId: String) async throws -> AtlasTraceChangeReviewResponse {
        let trace = traceId.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? traceId
        return try await get("/ai/interactions/\(trace)/change-review")
    }

    public func getTraceChangeReviewDiff(
        traceId: String,
        patchId: String,
        maxBytes: Int? = nil
    ) async throws -> AtlasTraceChangeReviewDiffResponse {
        let trace = traceId.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? traceId
        let patch = patchId.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? patchId
        let query = maxBytes.map { "?max_bytes=\(min(max($0, 1024), 1_048_576))" } ?? ""
        return try await get("/ai/interactions/\(trace)/change-review/patches/\(patch)/diff\(query)")
    }

    public func applyTraceChangeReview(
        traceId: String,
        input: AtlasTraceChangeReviewActionInput
    ) async throws -> AtlasTraceChangeReviewActionResponse {
        let trace = traceId.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? traceId
        return try await post("/ai/interactions/\(trace)/change-review/action", body: input)
    }

    public func applyTraceChangeReviewFile(
        traceId: String,
        input: AtlasTraceChangeReviewFileActionInput
    ) async throws -> AtlasTraceChangeReviewFileActionResponse {
        let trace = traceId.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? traceId
        return try await post("/ai/interactions/\(trace)/change-review/file-action", body: input)
    }
}
