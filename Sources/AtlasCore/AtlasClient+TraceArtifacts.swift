import CryptoKit
import Foundation

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
