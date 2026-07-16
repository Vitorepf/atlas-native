import Foundation
import AtlasCore

public func runAtlasTraceArtifactsChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas AI · artefatos do trace (V4):")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    let available = """
    {"schema_version":"atlas.trace_artifacts.v1","state":"available",
      "run":{"workspace_label":"atlas-native"},
      "items":[{"id":"art_1","kind":"markdown","name":"relatorio-final.md","relative_dir":"docs","byte_size":18,"sha256":"\(String(repeating: "a", count: 64))","created_at":"2026-07-16T21:00:00Z","origin":"produced"}]}
    """
    let decoded = try? decoder.decode(AtlasTraceArtifacts.self, from: Data(available.utf8))
    check("artifacts_decode_available",
          decoded?.state == .available &&
          decoded?.workspaceLabel == "atlas-native" &&
          decoded?.items.first?.kind == .markdown &&
          decoded?.items.first?.relativeDir == "docs" &&
          decoded?.items.first?.createdAt != nil)

    let unknownSchema = available.replacingOccurrences(of: "atlas.trace_artifacts.v1", with: "atlas.trace_artifacts.v2")
    check("artifacts_schema_unknown_fails_closed",
          (try? decoder.decode(AtlasTraceArtifacts.self, from: Data(unknownSchema.utf8))) == nil)

    let unavailableWithItems = """
    {"schema_version":"atlas.trace_artifacts.v1","state":"unavailable","reason":"no_run",
      "items":[{"id":"art_1","kind":"text","name":"x.txt","byte_size":1,"sha256":"\(String(repeating: "b", count: 64))"}]}
    """
    check("artifacts_invariant_unavailable_no_items",
          (try? decoder.decode(AtlasTraceArtifacts.self, from: Data(unavailableWithItems.utf8))) == nil)

    let unknownKind = available.replacingOccurrences(of: "\"markdown\"", with: "\"not-yet-known\"")
    let unknownKindDecoded = try? decoder.decode(AtlasTraceArtifacts.self, from: Data(unknownKind.utf8))
    check("artifacts_kind_unknown_maps_file", unknownKindDecoded?.items.first?.kind == .file)

    do {
        _ = try AtlasArtifactContent.validated(
            data: Data("conteudo".utf8),
            contentType: "text/plain",
            expectedSha256: String(repeating: "0", count: 64)
        )
        check("artifacts_sha_mismatch_throws", false)
    } catch AtlasTraceArtifactsError.artifactShaMismatch {
        check("artifacts_sha_mismatch_throws", true)
    } catch {
        check("artifacts_sha_mismatch_throws", false)
    }

    check("artifacts_maxbytes_in_query",
          AtlasRoute.aiInteractionArtifactContent(traceId: "tr/1", artifactId: "art 2", maxBytes: 9) == "/ai/interactions/tr%2F1/artifacts/art%202/content?max_bytes=9")
}
