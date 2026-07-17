import Foundation
import AtlasCore

public func runAtlasAiSessionsLiveChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas AI · sessões vivas entre superfícies (M13):")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    let liveJSON = """
    {"schema_version":"atlas.ai.sessions.live.v1","count":1,"generated_at":"2026-07-17T04:01:00Z",
     "sessions":[{"thread_id":"thread-1","title":"Sessão ativa","phase_title":"Executando ferramenta",
       "timing":"running","elapsed_active_ms":7000,"running_since":"2026-07-17T04:00:00+00:00"}]}
    """
    let live = try? decoder.decode(AtlasAiSessionsLiveResponse.self, from: Data(liveJSON.utf8))
    check("M13 decodifica envelope versionado e sessão remota sem trace",
          live?.schemaVersion == AtlasAiSessionsLiveResponse.schemaVersion &&
          live?.count == 1 &&
          live?.sessions.first?.threadId == ThreadID("thread-1") &&
          live?.sessions.first?.timing == .running &&
          live?.sessions.first?.elapsedActiveMs == 7000 &&
          live?.sessions.first?.runningSinceDate == Date(timeIntervalSince1970: 1_784_260_800))

    let wrongSchema = liveJSON.replacingOccurrences(
        of: "atlas.ai.sessions.live.v1",
        with: "atlas.ai.sessions.live.v0"
    )
    check("M13 schema desconhecido falha fechado",
          (try? decoder.decode(AtlasAiSessionsLiveResponse.self, from: Data(wrongSchema.utf8))) == nil)

    let unknownTiming = liveJSON.replacingOccurrences(of: "\"running\"", with: "\"almost_done\"")
    check("M13 timing desconhecido falha fechado",
          (try? decoder.decode(AtlasAiSessionsLiveResponse.self, from: Data(unknownTiming.utf8))) == nil)

    let negativeElapsed = liveJSON.replacingOccurrences(of: "\"elapsed_active_ms\":7000", with: "\"elapsed_active_ms\":-1")
    check("M13 tempo ativo negativo falha fechado",
          (try? decoder.decode(AtlasAiSessionsLiveResponse.self, from: Data(negativeElapsed.utf8))) == nil)

    let mismatchedCount = liveJSON.replacingOccurrences(of: "\"count\":1", with: "\"count\":2")
    check("M13 count inconsistente falha fechado",
          (try? decoder.decode(AtlasAiSessionsLiveResponse.self, from: Data(mismatchedCount.utf8))) == nil)

    check("M13 rota encoda instalação",
          AtlasRoute.aiSessionsLive(installation: "install/1 234567890") == "/ai/sessions/live?installation=install%2F1%20234567890")
}
