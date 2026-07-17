import Foundation
import AtlasCore

public func runAtlasNativeSnapshotChecks(_ check: (String, Bool) -> Void) async {
    print("\nAtlas Native Snapshot · SD-1 App Group:")

    let fixedDate = Date(timeIntervalSince1970: 1_784_188_800)
    let snapshot = AtlasNativeSnapshot(
        generatedAt: fixedDate,
        liveSessions: [
            AtlasNativeSnapshot.LiveSession(
                title: "Refatorar parser SSE",
                phaseTitle: "4/6 · rodando testes",
                timing: .running,
                elapsedActiveMs: 91_000,
                runningSince: "2026-07-17T04:00:00Z"
            )
        ],
        fleet: AtlasNativeSnapshot.Fleet(
            scannedAt: "2026-07-17T03:45:00Z",
            incident: nil,
            lastDelivery: AtlasNativeSnapshot.Fleet.LastDelivery(
                title: "Snapshot App Group",
                mergeHash: "abc1234",
                at: "2026-07-17T03:30:00Z"
            )
        ),
        week: AtlasNativeSnapshot.Week(
            window: "2026-W29",
            commits: 12,
            heals: 2,
            prevented: 1
        ),
        queuedCount: 3
    )

    do {
        let encoder = JSONEncoder.atlasNativeSnapshotEncoder()
        let data = try encoder.encode(snapshot)
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        check("schema SD-1 usa versão exata",
              object?["schema_version"] as? String == AtlasNativeSnapshot.schemaVersion)
        check("path SD-1 é fixo",
              AtlasNativeSnapshot.relativePath == "snapshot/atlas.native.snapshot.v1.json")
        check("encode SD-1 usa snake_case",
              object?["generated_at"] is String &&
              object?["live_sessions"] != nil &&
              object?["queued_count"] as? Int == 3)

        let decoded = try JSONDecoder.atlasNativeSnapshotDecoder().decode(AtlasNativeSnapshot.self, from: data)
        check("encode/decode preserva snapshot compartilhado", decoded == snapshot)
    } catch {
        check("encode/decode snapshot compartilhado", false)
    }

    let wrongVersion = """
    {"schema_version":"atlas.native.snapshot.v0","generated_at":"2026-07-17T04:00:00Z","queued_count":1}
    """.data(using: .utf8)!
    let rejected = (try? JSONDecoder.atlasNativeSnapshotDecoder().decode(AtlasNativeSnapshot.self, from: wrongVersion)) == nil
    check("versão errada falha fechado", rejected)

    let temp = FileManager.default.temporaryDirectory
        .appendingPathComponent("atlas-native-snapshot-\(UUID().uuidString)", isDirectory: true)
    let file = temp.appendingPathComponent(AtlasNativeSnapshot.relativePath)
    do {
        let store = AtlasNativeSnapshotStore(fileURL: file)
        try await store.save(snapshot)
        let loaded = try await store.load()
        check("writer atômico cria snapshot/path e reader carrega", loaded == snapshot)
    } catch {
        check("writer atômico cria snapshot/path e reader carrega", false)
    }
}
