import Foundation
import AtlasCore

// Golden self-check for the AtlasCore substrate. Same contract as the RN-side
// `scripts/*.test.ts`: exits non-zero if any check fails. Runnable with plain
// Command Line Tools via `swift run AtlasCoreChecks` (no XCTest/swift-testing).

private final class CheckRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var failures = 0

    func record(_ name: String, _ condition: Bool) {
        lock.lock(); defer { lock.unlock() }
        if condition { print("  ✓ \(name)") }
        else { print("  ✗ \(name)"); failures += 1 }
    }

    var failureCount: Int {
        lock.lock(); defer { lock.unlock() }
        return failures
    }
}
private let recorder = CheckRecorder()
let check: (String, Bool) -> Void = { recorder.record($0, $1) }

@inline(never)
func isGreaterThanOrEqual(_ lhs: Double, _ rhs: Double) -> Bool { lhs >= rhs }

print("AtlasTime (parsing ISO8601 tolerante — gotcha #1):")
check("plain ISO parses", abs(AtlasTime.ms("2026-01-01T00:00:00Z") - 1767225600000) < 1)
do {
    let base = AtlasTime.ms("2026-01-01T00:00:00Z")
    let frac = AtlasTime.ms("2026-01-01T00:00:00.500Z")
    check("fractional seconds parses (não NaN)", !frac.isNaN)
    check("fractional delta = 500ms", abs((frac - base) - 500) < 1)
}
check("nil → NaN", AtlasTime.ms(nil).isNaN)
check("empty → NaN", AtlasTime.ms("").isNaN)
check("garbage → NaN", AtlasTime.ms("not-a-date").isNaN)
check("mês inválido → NaN", AtlasTime.ms("2026-13-99").isNaN)
do {
    let nan = AtlasTime.ms("garbage"), nan2 = AtlasTime.ms("also-bad"), real = AtlasTime.ms("2026-01-01T00:00:00Z")
    check("NaN >= real é false (semântica JS)", !isGreaterThanOrEqual(nan, real))
    check("real >= NaN é false", !isGreaterThanOrEqual(real, nan))
    check("NaN >= NaN é false", !isGreaterThanOrEqual(nan, nan2))
}

print("\nAtlas AI · SSE dispatch (núcleo de correção, verbatim de atlasAiStreamRuntime.ts):")
do {
    let frame = "event: message\ndata: {\"trace_id\":\"t1\",\"sequence\":3,\"type\":\"delta\",\"content\":\"olá\"}"
    if case .event(let e) = dispatchAtlasAiStreamFrame(frame) {
        check("event decodou trace_id/sequence", e.traceId == "t1" && e.sequence == 3)
        check("event type/content preservados", e.type == "delta" && e.content == "olá")
    } else { check("event frame deu .event", false) }
}
check("type cai pro eventName quando payload não tem type", {
    if case .event(let e) = dispatchAtlasAiStreamFrame("event: token\ndata: {\"trace_id\":\"t\",\"sequence\":1}") {
        return e.type == "token" && e.content == "" && e.metadata.isEmpty
    }; return false }())
do {
    let done = dispatchAtlasAiStreamFrame("event: done\ndata: {\"trace_id\":\"t\",\"status\":\"succeeded\",\"last_sequence\":9}")
    if case .done(let d) = done { check("done decodou status + last_sequence", d.status == "succeeded" && d.lastSequence == 9) }
    else { check("done frame deu .done", false) }
}
check("done sem status → .ignored", dispatchAtlasAiStreamFrame("event: done\ndata: {\"trace_id\":\"t\"}") == .ignored)
check("error emite payload cru", {
    if case .error(let p) = dispatchAtlasAiStreamFrame("event: error\ndata: {\"code\":\"boom\"}") { return p["code"]?.stringValue == "boom" }
    return false }())
check("heartbeat → .ignored", dispatchAtlasAiStreamFrame("event: heartbeat\ndata: {}") == .ignored)
check("frame sem data: → .ignored", dispatchAtlasAiStreamFrame("event: message\n: comentário") == .ignored)
check("JSON inválido → .ignored", dispatchAtlasAiStreamFrame("data: {não é json}") == .ignored)
check("event sem trace_id → .ignored", dispatchAtlasAiStreamFrame("data: {\"sequence\":1}") == .ignored)
check("event sem sequence → .ignored", dispatchAtlasAiStreamFrame("data: {\"trace_id\":\"t\"}") == .ignored)
check("data: multi-linha junta com \\n", {
    if case .event(let e) = dispatchAtlasAiStreamFrame("data: {\"trace_id\":\"t\",\"sequence\":1,\ndata: \"content\":\"x\"}") { return e.content == "x" }
    return false }())
do {
    let frames = parseAtlasAiSseFrames("a: 1\n\n\r\n\r\nb: 2\n\n   \n\n")
    check("parseFrames split por linha-em-branco + drop vazios", frames == ["a: 1", "b: 2"])
}
runAtlasAiStreamFrameChecks(check)

print("\nqueryString (gotchas de core.ts — limit clamp + boolean 1/0):")
check("vazio → \"\"", atlasQueryString([]) == "")
check("pula nil e string vazia", atlasQueryString([("a", nil), ("b", .string(""))]) == "")
check("limit clampa 500→200", atlasQueryString([("limit", .int(500))]) == "?limit=200")
check("limit clampa 0→1 e -5→1", atlasQueryString([("limit", .int(0))]) == "?limit=1" && atlasQueryString([("limit", .int(-5))]) == "?limit=1")
check("boolean vira 1/0", atlasQueryString([("light", .bool(true)), ("x", .bool(false))]) == "?light=1&x=0")
check("encoda valores (espaço/&)", atlasQueryString([("q", .string("a b&c"))]) == "?q=a%20b%26c")
check("ordem de inserção preservada", atlasQueryString([("status", .string("active")), ("limit", .int(10))]) == "?status=active&limit=10")

print("\nAtlasRoute (constantes de path e segmentos codificados):")
runAtlasRouteChecks(check)

print("\nJSONValue (ponte JSONSerialization sem alterar contrato Codable):")
do {
    let json = Data("""
    {"trace_id":"t-1","pinned":true,"score":4.5,"items":[null,"ok"],"meta":{"empty":[]}}
    """.utf8)
    let value = try JSONDecoder().decode(JSONValue.self, from: json)
    check("JSONValue preserva objeto/array/escalares", {
        guard case .object(let obj) = value else { return false }
        return obj["trace_id"]?.stringValue == "t-1"
            && obj["pinned"]?.boolValue == true
            && obj["score"]?.doubleValue == 4.5
            && obj["items"] == .array([.null, .string("ok")])
            && obj["meta"]?["empty"] == .array([])
    }())

    let snakeDecoder = JSONDecoder()
    snakeDecoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    let snakeValue = try snakeDecoder.decode(JSONValue.self, from: Data("{\"trace_id\":\"t-2\"}".utf8))
    check("JSONValue direto preserva chaves cruas", snakeValue["trace_id"]?.stringValue == "t-2")

    struct MetadataEnvelope: Decodable { let metadata: JSONObject }
    let envelope = try snakeDecoder.decode(MetadataEnvelope.self, from: Data("""
    {"metadata":{"item_id":"bag-item","exit_code":0}}
    """.utf8))
    check("JSONObject aninhado preserva chaves cruas",
          envelope.metadata["item_id"]?.stringValue == "bag-item" &&
          envelope.metadata["exit_code"]?.doubleValue == 0 &&
          envelope.metadata["itemId"] == nil)

    check("JSONObject decoda objeto", (try JSONDecoder().decode(JSONObject.self, from: json))["trace_id"]?.stringValue == "t-1")
    check("JSONObject mantém [] Laravel como bag vazio",
          (try JSONDecoder().decode(JSONObject.self, from: Data("[]".utf8))).isEmpty)
    check("JSONObject mantém não-objeto como bag vazio",
          (try JSONDecoder().decode(JSONObject.self, from: Data("\"x\"".utf8))).isEmpty)
} catch {
    check("JSONValue/JSONObject decode sem erro", false)
    print("    erro: \(error)")
}

print("\nAtlas AI · Codable DTOs (snake_case → camelCase, o loop de conversa):")
do {
    let json = """
    {"threads":[{"id":"th-1","title":"Plano Swift","summary":null,"status":"active",
      "surface":"mobile","workspace":null,"source_type":null,"source_id":null,
      "last_trace_id":"tr-9","last_provider":"claude_cli","message_count":2,
      "last_message_at":"2026-07-12T10:00:00Z","metadata":{"pinned":true},
      "messages":[{"id":"m-1","thread_id":"th-1","trace_id":null,"position":0,
        "role":"user","status":"final","content":"oi","provider":null,"model":null,
        "agent_slug":null,"token_estimate":3,"occurred_at":null,"metadata":{},
        "created_at":"2026-07-12T10:00:00Z","updated_at":"2026-07-12T10:00:00Z"}],
      "active_session":null,
      "created_at":"2026-07-12T09:00:00Z","updated_at":"2026-07-12T10:00:00Z"}]}
    """.data(using: .utf8)!
    let dec = JSONDecoder(); dec.keyDecodingStrategy = atlasSnakeKeyDecoding
    if let resp = try? dec.decode(AiThreadsResponse.self, from: json), let th = resp.threads.first {
        check("thread snake→camel (last_trace_id, message_count)", th.lastTraceId == "tr-9" && th.messageCount == 2)
        check("metadata JSONValue bool", th.metadata?["pinned"]?.boolValue == true)
        check("message aninhada decodou", th.messages?.first?.content == "oi" && th.messages?.first?.tokenEstimate == 3)
        check("null → optional nil (summary/activeSession)", th.summary == nil && th.activeSession == nil)
    } else { check("decode AiThreadsResponse falhou", false) }
}

print("\nAtlas AI · CreateAiInteractionInput (Encodable → snake_case, omite nil):")
do {
    let enc = JSONEncoder(); enc.keyEncodingStrategy = .convertToSnakeCase
    let input = CreateAiInteractionInput(inputText: "oi", newThread: true, provider: "claude_cli")
    if let data = try? enc.encode(input), let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        check("inputText → input_text", obj["input_text"] as? String == "oi")
        check("newThread → new_thread", obj["new_thread"] as? Bool == true)
        check("nil omitido (sem thread_id/session_id)", obj["thread_id"] == nil && obj["session_id"] == nil)
    } else { check("encode CreateAiInteractionInput falhou", false) }
}

print("\nAtlas AI · TurnPayloadBuilder (equivalência do payload do turno):")
runTurnPayloadBuilderChecks(check)

print("\nAtlasClient (engine de rede — check AO VIVO contra 127.0.0.1:3737, sem CORS):")
do {
    let client = AtlasClient(config: AtlasConfig(host: "127.0.0.1", port: 3737))
    let health: AtlasHealthResponse = try await client.get("/health", auth: false)
    check("GET /health decodou e status == ok", health.status == "ok")
    print("    service=\(health.service ?? "?") · version=\(health.version ?? "?") · db=\(health.dbConnected.map { $0 ? "connected" : "down" } ?? "?")")
} catch {
    print("  ⚠ servidor não alcançável — check de rede pulado (não conta como falha): \(error)")
}

print("\nAtlas AI · superfície completa (golden decode por cluster):")
runJobsChecks(check)
runAtlasLiveActivityChecks(check)
runAtlasExecutionPlanChecks(check)
runAtlasExecutionPresentationStateChecks(check)
runAtlasChangeReviewChecks(check)
runAtlasCodeGraphChecks(check)
runAtlasCodeFactsChecks(check)
runAtlasTraceGovernanceChecks(check)
runAtlasAutonomosChecks(check)
await runAtlasDayRhythmChecks(check)
runQualityChecks(check)
runThreadsExtraChecks(check)

print("\nAtlasMarkdown (parser editorial, verbatim de markdown/parse.ts):")
do {
    let spans = AtlasMarkdown.parseInline("olá **mundo** e `code` e *ital*")
    check("inline: text+bold+code+italic", spans == [
        .text("olá "), .bold("mundo"), .text(" e "), .code("code"), .text(" e "), .italic("ital")
    ])
}
check("inline: link", AtlasMarkdown.parseInline("[Atlas](https://x.y)") == [.link(text: "Atlas", url: "https://x.y")])
check("inline: ***bold-italic*** vira italic", AtlasMarkdown.parseInline("***x***") == [.italic("x")])
check("inline: escape \\* fica literal", AtlasMarkdown.parseInline("a \\* b") == [.text("a * b")])
do {
    let blocks = AtlasMarkdown.parse("# Título\n\ntexto **forte**\n\n- um\n- dois\n\n```swift\nlet x = 1\n```")
    check("blocos: heading H1", blocks.first == .heading(level: 1, spans: [.text("Título")]))
    if case .list(let ordered, let items)? = blocks.first(where: { if case .list = $0 { return true }; return false }) {
        check("blocos: lista não-ordenada 2 itens", !ordered && items.count == 2)
    } else { check("blocos: lista", false) }
    if case .code(let t, let lang)? = blocks.first(where: { if case .code = $0 { return true }; return false }) {
        check("blocos: code fence com lang", t == "let x = 1" && lang == "swift")
    } else { check("blocos: code fence", false) }
    check("blocos: parágrafo com bold", blocks.contains(.paragraph([.text("texto "), .bold("forte")])))
}
check("blocos: divider ---", AtlasMarkdown.parse("---") == [.divider])
do {
    let h3 = AtlasMarkdown.parse("### Estado Atual")
    check("blocos: heading H3", h3 == [.heading(level: 3, spans: [.text("Estado Atual")])])
}

print("\nAtlasComputeEffort (dial de esforço · canon computeEffort.ts):")
check("ciclo auto→fast→balanced→deep→max→auto",
      AtlasComputeEffort.auto.next == .fast && AtlasComputeEffort.max.next == .auto)
check("auto não vai no payload (Atlas Decide escolhe)", AtlasComputeEffort.auto.payloadValue == nil)
check("deep vai como 'deep' no payload", AtlasComputeEffort.deep.payloadValue == "deep")
check("label PT-BR", AtlasComputeEffort.balanced.shortLabel == "normal" && AtlasComputeEffort.deep.shortLabel == "profundo")

print("\nAtlas AI · loop de conversa AO VIVO (só roda com ATLAS_TOKEN no env — sem segredo no arquivo):")
if let token = ProcessInfo.processInfo.environment["ATLAS_TOKEN"], !token.isEmpty {
    do {
        let client = AtlasClient(config: AtlasConfig(host: "127.0.0.1", port: 3737, token: token))
        let threads = try await client.listAiThreads(light: true, limit: 2)
        check("GET /ai/threads decodou (DTO real do servidor)", true)
        print("    \(threads.threads.count) thread(s):")
        for t in threads.threads.prefix(2) {
            print("      · \(t.title.prefix(44)) — \(t.messageCount) msgs · \(t.surface)")
        }

        let jobs = try await client.listAiJobs(limit: 3)
        check("GET /ai/jobs decodou (fila real)", true)
        print("    \(jobs.jobs.count) job(s) recentes")
    } catch {
        check("GET AI surface AO VIVO", false)
        print("    erro: \(error)")
    }
} else {
    print("  ⚠ ATLAS_TOKEN ausente — check de AI ao vivo pulado (não conta como falha)")
}

print("\nAtlasTurnStatus (lifecycle tipado do turno):")
runTurnStatusChecks(check)
runAtlasIDChecks(check)

runRichInputChecks(check)
await runRichInputEngineChecks(check)
runRichInputBoundaryChecks(check)
await runInteractionRunChecks(check)
await runInteractionOutboxChecks(check)
await runThreadReadCacheChecks(check)
await runAtlasQueuedFollowUpChecks(check)
runAttachmentAdapterChecks(check)
await runLongMessageChecks(check)
runAssistantPresentationChecks(check)
await runAtlasImagingChecks(check)
runDeviceProofHarnessChecks(check)

// Live-probe do upload (opt-in ATLAS_LIVE=1: sobe bytes reais no staging do
// atlas-server e prova sha+resume — gate recomendado do `make device`).
if ProcessInfo.processInfo.environment["ATLAS_LIVE"] == "1",
   let liveToken = ProcessInfo.processInfo.environment["ATLAS_TOKEN"], !liveToken.isEmpty {
    let liveHost = ProcessInfo.processInfo.environment["ATLAS_HOST"] ?? "127.0.0.1"
    let liveClient = AtlasClient(config: AtlasConfig(host: liveHost, port: 3737, token: liveToken))
    let liveScope = ProcessInfo.processInfo.environment["ATLAS_LIVE_SCOPE"]
    if liveScope != "tools" {
        await runInteractionRunLiveProbe(check, client: liveClient)
    }
    if ProcessInfo.processInfo.environment["ATLAS_LIVE_TOOLS"] == "1" {
        let provider = ProcessInfo.processInfo.environment["ATLAS_LIVE_TOOL_PROVIDER"] ?? "codex_cli"
        await runProviderToolActivityLiveProbe(check, client: liveClient, provider: provider)
    }
    if liveScope != "tools" {
        await runRichInputLiveProbe(check, client: liveClient)
        await runLongMessageLiveProbe(check, client: liveClient)
    }
} else {
    print("\n  ⚠ ATLAS_LIVE≠1 — live-probe de upload pulado (rode ATLAS_LIVE=1 ATLAS_TOKEN=… antes do make device)")
}

print("")
if recorder.failureCount == 0 { print("AtlasCore: todos os checks passaram ✓") }
else { print("AtlasCore: \(recorder.failureCount) check(s) FALHARAM ✗"); exit(1) }
