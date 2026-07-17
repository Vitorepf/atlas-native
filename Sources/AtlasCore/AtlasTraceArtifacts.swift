import Foundation

public enum AtlasTraceArtifactsError: Error, Equatable, Sendable {
    case artifactShaMismatch(expected: String, actual: String)
}

public struct AtlasTraceArtifacts: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.trace_artifacts.v1"

    public enum State: String, Decodable, Sendable { case available, unavailable }

    public let schemaVersion: String
    public let state: State
    public let reason: String?
    public let workspaceLabel: String?
    public let items: [Item]

    private struct Run: Decodable {
        let workspaceLabel: String?
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, state, reason, run, items
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported trace artifacts schema.")
        state = try values.decode(State.self, forKey: .state)
        reason = try values.decodeIfPresent(String.self, forKey: .reason)
        let run = try values.decodeIfPresent(Run.self, forKey: .run)
        workspaceLabel = run?.workspaceLabel

        switch state {
        case .available:
            if run == nil {
                throw DecodingError.dataCorruptedError(forKey: .run, in: values, debugDescription: "Available artifacts require a bound run.")
            }
            items = try values.decode([Item].self, forKey: .items)
        case .unavailable:
            if run != nil {
                throw DecodingError.dataCorruptedError(forKey: .run, in: values, debugDescription: "Unavailable artifacts cannot expose a run.")
            }
            let decodedItems = try values.decodeIfPresent([Item].self, forKey: .items) ?? []
            if !decodedItems.isEmpty {
                throw DecodingError.dataCorruptedError(forKey: .items, in: values, debugDescription: "Unavailable artifacts cannot expose items.")
            }
            items = []
        }
    }
}
