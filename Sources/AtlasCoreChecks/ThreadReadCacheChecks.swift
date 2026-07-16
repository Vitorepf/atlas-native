import Foundation
import AtlasCore

public func runThreadReadCacheChecks(_ check: (String, Bool) -> Void) async {
    print("\nAtlas AI · cache de leitura de thread (F6.1):")
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("atlas-thread-read-cache-check-\(UUID().uuidString)", isDirectory: true)
    let file = directory.appendingPathComponent("thread-read-cache.json")
    defer { try? FileManager.default.removeItem(at: directory) }

    do {
        let cache = ThreadReadCache(fileURL: file)
        let capturedAt = Date(timeIntervalSince1970: 1_786_000_000)
        let snapshot = ThreadReadCache.Snapshot(
            threadId: "thread-1",
            capturedAt: capturedAt,
            workspacePath: "/Users/vitorepf/develop/Atlas",
            messages: [
                .init(id: "m-user", role: "user", content: "oi", traceId: nil, provider: nil, model: nil),
                .init(id: "m-assistant", role: "assistant", content: "olá", traceId: "tr-1", provider: "codex_cli", model: "gpt-5.5"),
            ]
        )

        try await cache.save(snapshot: snapshot)
        check("save cria arquivo JSON atômico", FileManager.default.fileExists(atPath: file.path))

        let relaunched = ThreadReadCache(fileURL: file)
        let loaded = await relaunched.load(threadId: "thread-1")
        check("save→load preserva snapshot completo", loaded == snapshot)
        check("load de outra thread não mistura histórico", await relaunched.load(threadId: "thread-2") == nil)
    } catch {
        check("cache de leitura não deveria falhar", false)
        print("    erro: \(error)")
    }
}
