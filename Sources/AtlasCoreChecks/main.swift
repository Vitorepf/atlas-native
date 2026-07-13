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

func cap(_ client: String, updated: String, captured: String = "2026-01-01T00:00:00Z",
         content: String? = nil, deleted: String? = nil) -> AtlasCapture {
    AtlasCapture(clientId: client, updatedAt: updated, deletedAt: deleted,
                 capturedAt: captured, contentText: content)
}

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

print("\nMerge core (LWW + tombstone, verbatim de storeConverters.ts):")
do {
    let v1 = cap("a", updated: "2026-01-01T00:00:00Z", content: "v1")
    let v2 = cap("a", updated: "2026-01-02T00:00:00Z", content: "v2")
    check("LWW independe de ordem [v1,v2]", mergeCaptures([v1, v2]).map(\.contentText) == ["v2"])
    check("LWW independe de ordem [v2,v1]", mergeCaptures([v2, v1]).map(\.contentText) == ["v2"])
}
do {
    let x = cap("a", updated: "2026-01-01T00:00:00Z", content: "x")
    let y = cap("a", updated: "2026-01-01T00:00:00Z", content: "y")
    check("empate (>=) favorece o último visto [x,y]→y", mergeCaptures([x, y]).map(\.contentText) == ["y"])
    check("empate [y,x]→x", mergeCaptures([y, x]).map(\.contentText) == ["x"])
}
do {
    let a = cap("a", updated: "2026-01-01T00:00:00Z")
    let b = cap("b", updated: "2026-01-01T00:00:00Z")
    let aDel = cap("a", updated: "2026-01-02T00:00:00Z", deleted: "2026-01-02T00:00:00Z")
    check("tombstone remove o client_id", mergeCaptures([a, b, aDel]).map(\.clientId) == ["b"])
}
check("deleted_at vazio NÃO deleta (JS truthy)",
      mergeCaptures([cap("a", updated: "2026-01-01T00:00:00Z", deleted: "")]).map(\.clientId) == ["a"])
do {
    let valid = cap("a", updated: "2026-01-01T00:00:00Z", content: "valid")
    let bad = cap("a", updated: "not-a-date", content: "bad")
    check("updated_at inválido mantém existente [valid,bad]→valid", mergeCaptures([valid, bad]).map(\.contentText) == ["valid"])
    check("updated_at inválido mantém existente [bad,valid]→bad", mergeCaptures([bad, valid]).map(\.contentText) == ["bad"])
}
do {
    let base = cap("a", updated: "2026-01-01T00:00:00Z", content: "base")
    let frac = cap("a", updated: "2026-01-01T00:00:00.500Z", content: "frac")
    check("frac-seconds vence base (o gotcha resolvido)", mergeCaptures([base, frac]).map(\.contentText) == ["frac"])
}
do {
    let a = cap("a", updated: "t", captured: "2026-01-01T00:00:00Z")
    let b = cap("b", updated: "t", captured: "2026-01-03T00:00:00Z")
    let c = cap("c", updated: "t", captured: "2026-01-02T00:00:00Z")
    check("sort desc por captured_at", mergeCaptures([a, b, c]).map(\.clientId) == ["b", "c", "a"])
}
do {
    let a = cap("a", updated: "2026-01-01T00:00:00Z", captured: "2026-01-01T00:00:00Z", content: "old")
    let b = cap("b", updated: "t", captured: "2026-01-02T00:00:00Z")
    let aDel = cap("a", updated: "2026-01-02T00:00:00Z", deleted: "2026-01-02T00:00:00Z")
    let aNew = cap("a", updated: "2026-01-05T00:00:00Z", captured: "2026-01-05T00:00:00Z", content: "new")
    let out = mergeCaptures([a, b, aDel, aNew])
    check("delete-then-readd sobrevive com dado novo (ordem)", out.map(\.clientId) == ["a", "b"])
    check("delete-then-readd usa o valor re-adicionado", out.first?.contentText == "new")
}
do {
    let a = cap("a", updated: "t", captured: "2026-01-01T00:00:00Z")
    let b = cap("b", updated: "t", captured: "2026-01-01T00:00:00Z")
    check("empate no sort = ordem de inserção estável [a,b]", mergeCaptures([a, b]).map(\.clientId) == ["a", "b"])
    check("empate estável [b,a]", mergeCaptures([b, a]).map(\.clientId) == ["b", "a"])
}
do {
    let a = AtlasCheckin(clientId: "a", updatedAt: "t", recordedAt: "2026-01-01T00:00:00Z")
    let b = AtlasCheckin(clientId: "b", updatedAt: "t", recordedAt: "2026-01-02T00:00:00Z")
    check("checkins ordenam por recorded_at", mergeCheckins([a, b]).map(\.clientId) == ["b", "a"])
}

print("\nCodable (snake_case + JSONValue metadata bag):")
do {
    let json = """
    {"id":"srv-1","client_id":"a","updated_at":"2026-01-01T00:00:00Z","deleted_at":null,
     "captured_at":"2026-01-01T00:00:00Z","content_text":"hi",
     "metadata":{"lat":1.5,"tag":"note","ok":true}}
    """.data(using: .utf8)!
    let dec = JSONDecoder(); dec.keyDecodingStrategy = atlasSnakeKeyDecoding
    if let capture = try? dec.decode(AtlasCapture.self, from: json) {
        check("decode snake_case → camelCase", capture.clientId == "a" && capture.contentText == "hi")
        check("metadata JSONValue: número", capture.metadata?["lat"]?.doubleValue == 1.5)
        check("metadata JSONValue: string", capture.metadata?["tag"]?.stringValue == "note")
        check("metadata JSONValue: bool", capture.metadata?["ok"]?.boolValue == true)
    } else {
        check("decode snake_case falhou", false)
    }
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

print("\nqueryString (gotchas de core.ts — limit clamp + boolean 1/0):")
check("vazio → \"\"", atlasQueryString([]) == "")
check("pula nil e string vazia", atlasQueryString([("a", nil), ("b", .string(""))]) == "")
check("limit clampa 500→200", atlasQueryString([("limit", .int(500))]) == "?limit=200")
check("limit clampa 0→1 e -5→1", atlasQueryString([("limit", .int(0))]) == "?limit=1" && atlasQueryString([("limit", .int(-5))]) == "?limit=1")
check("boolean vira 1/0", atlasQueryString([("light", .bool(true)), ("x", .bool(false))]) == "?light=1&x=0")
check("encoda valores (espaço/&)", atlasQueryString([("q", .string("a b&c"))]) == "?q=a%20b%26c")
check("ordem de inserção preservada", atlasQueryString([("status", .string("active")), ("limit", .int(10))]) == "?status=active&limit=10")

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
runProvidersChecks(check)
runDecisionsChecks(check)
runTelemetryChecks(check)
runPoliciesChecks(check)
runQualityChecks(check)
runAttachmentsChecks(check)
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

        // Prova real dos clusters admin (payloads pesados — o Providers é o que
        // pegou o bug 24H; decodar o real fecha o loop).
        let status = try await client.getAiProvidersStatus()
        check("GET /ai/providers/status decodou (payload admin real)", true)
        print("    fila: \(status.queue.queued) queued · \(status.queue.processing) processing · providers: \(status.providers.count)")
        for p in status.providers.prefix(3) {
            print("      · \(p.provider): \(p.status) — \(p.totalJobs24h) jobs/24h, \(p.failedJobs24h) falhas")
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

runRichInputChecks(check)
await runRichInputEngineChecks(check)
runRichInputBoundaryChecks(check)
await runInteractionRunChecks(check)
await runInteractionOutboxChecks(check)
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
