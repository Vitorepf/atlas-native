import Foundation

/// Conselho (C21) — peel de AtlasTraceGovernance.

extension AtlasTraceGovernance {
    public struct CouncilMember: Equatable, Sendable, Identifiable {
        public let provider: String
        public let model: String?
        public let status: String
        public let responseHash: String?
        public let errorCode: String?
        public let latencyMs: Int?

        public var id: String { provider }

        public var succeeded: Bool { status == "succeeded" }
    }

    public static func councilReview(from metadata: JSONObject?) -> [CouncilMember] {
        guard let raw = array(metadata?["council_review"]) else { return [] }
        return raw.compactMap { entry in
            guard let item = object(entry),
                  let provider = string(item["provider"]),
                  let status = string(item["status"]) else { return nil }
            return CouncilMember(
                provider: provider,
                model: string(item["model"]),
                status: status,
                responseHash: string(item["response_hash"]),
                errorCode: string(item["error_code"]),
                latencyMs: int(item["latency_ms"])
            )
        }
    }

    public static func councilDiverged(_ members: [CouncilMember]) -> Bool {
        let statuses = Set(members.map(\.status))
        if statuses.count > 1 { return true }
        let hashes = Set(members.filter(\.succeeded).compactMap(\.responseHash))
        return hashes.count > 1
    }
}
