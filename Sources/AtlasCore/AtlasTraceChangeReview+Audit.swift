import Foundation

extension AtlasTraceChangeReview {
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
}
