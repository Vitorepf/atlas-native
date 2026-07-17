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
    public let traceId: TraceID
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

    /// A mesma taxonomia governa o aceite global e a decisão do arquivo. O
    /// escopo vem da rota e do recibo, nunca de uma ação local otimista.
    public enum Action: String, Codable, Sendable { case accept, reject }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, state, reason, traceId, run, patches, controls, testRuns, review
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported trace change review schema.")
        self.schemaVersion = schemaVersion
        self.state = try values.decode(State.self, forKey: .state)
        self.reason = try values.decodeIfPresent(String.self, forKey: .reason)
        self.traceId = try values.decode(TraceID.self, forKey: .traceId)
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
