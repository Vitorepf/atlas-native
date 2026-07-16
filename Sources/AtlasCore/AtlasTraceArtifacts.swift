import CryptoKit
import Foundation

public enum AtlasTraceArtifactsError: Error, Equatable, Sendable {
    case artifactShaMismatch(expected: String, actual: String)
}

public struct AtlasTraceArtifacts: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.trace_artifacts.v1"

    public enum State: String, Decodable, Sendable { case available, unavailable }

    public struct Item: Decodable, Sendable, Equatable, Identifiable {
        public enum Kind: String, Sendable { case image, markdown, text, diff, file }

        public let id: String
        public let kind: Kind
        public let name: String
        public let relativeDir: String?
        public let byteSize: Int
        public let sha256: String
        public let createdAt: Date?
        public let origin: String?

        private enum CodingKeys: String, CodingKey {
            case id, kind, name, relativeDir, byteSize, sha256, createdAt, origin
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            let rawKind = try values.decode(String.self, forKey: .kind)
            kind = Kind(rawValue: rawKind) ?? .file
            name = try values.decode(String.self, forKey: .name)
            relativeDir = try values.decodeIfPresent(String.self, forKey: .relativeDir)
            byteSize = try values.decode(Int.self, forKey: .byteSize)
            sha256 = try values.decode(String.self, forKey: .sha256)
            createdAt = AtlasTime.date(try values.decodeIfPresent(String.self, forKey: .createdAt))
            origin = try values.decodeIfPresent(String.self, forKey: .origin)

            if id.isEmpty {
                throw DecodingError.dataCorruptedError(forKey: .id, in: values, debugDescription: "Artifact id is required.")
            }
            if name.isEmpty || name.contains("/") || name.contains("\\") || name == "." || name == ".." {
                throw DecodingError.dataCorruptedError(forKey: .name, in: values, debugDescription: "Artifact name must be a safe lastPathComponent.")
            }
            if byteSize < 0 {
                throw DecodingError.dataCorruptedError(forKey: .byteSize, in: values, debugDescription: "Artifact byte_size cannot be negative.")
            }
            if !Self.isSha256(sha256) {
                throw DecodingError.dataCorruptedError(forKey: .sha256, in: values, debugDescription: "Artifact sha256 must be a lowercase hex digest.")
            }
            if let relativeDir, !Self.isSafeRelativeDir(relativeDir) {
                throw DecodingError.dataCorruptedError(forKey: .relativeDir, in: values, debugDescription: "Artifact relative_dir must be provider-safe.")
            }
        }

        private static func isSha256(_ value: String) -> Bool {
            value.count == 64 && value.utf8.allSatisfy { byte in
                (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
                    || (UInt8(ascii: "a")...UInt8(ascii: "f")).contains(byte)
            }
        }

        private static func isSafeRelativeDir(_ value: String) -> Bool {
            if value.isEmpty || value.hasPrefix("/") || value.contains("\\") { return false }
            let parts = value.split(separator: "/", omittingEmptySubsequences: false)
            guard (1...2).contains(parts.count) else { return false }
            return parts.allSatisfy { part in
                !part.isEmpty && part != "." && part != ".."
            }
        }
    }

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

public struct AtlasArtifactContent: Sendable, Equatable {
    public let data: Data
    public let contentType: String

    public init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }

    public static func validated(data: Data, contentType: String, expectedSha256: String) throws -> Self {
        let actual = sha256(data)
        if !actual.elementsEqual(expectedSha256) {
            throw AtlasTraceArtifactsError.artifactShaMismatch(expected: expectedSha256, actual: actual)
        }

        return Self(data: data, contentType: contentType)
    }

    private static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

extension AtlasClient {
    public func getTraceArtifacts(traceId: TraceID) async throws -> AtlasTraceArtifacts {
        try await get(AtlasRoute.aiInteractionArtifacts(traceId.rawValue))
    }

    public func getTraceArtifactContent(
        traceId: TraceID,
        artifactId: String,
        expectedSha256: String? = nil,
        maxBytes: Int = 5_242_880
    ) async throws -> AtlasArtifactContent {
        let response = try await getData(AtlasRoute.aiInteractionArtifactContent(
            traceId: traceId.rawValue,
            artifactId: artifactId,
            maxBytes: maxBytes
        ))

        guard let expectedSha256 else {
            return AtlasArtifactContent(data: response.data, contentType: response.contentType)
        }

        return try AtlasArtifactContent.validated(
            data: response.data,
            contentType: response.contentType,
            expectedSha256: expectedSha256
        )
    }

    public func getTraceArtifactContent(
        traceId: TraceID,
        item: AtlasTraceArtifacts.Item,
        maxBytes: Int = 5_242_880
    ) async throws -> AtlasArtifactContent {
        try await getTraceArtifactContent(
            traceId: traceId,
            artifactId: item.id,
            expectedSha256: item.sha256,
            maxBytes: maxBytes
        )
    }
}
