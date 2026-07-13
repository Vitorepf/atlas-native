import Foundation
import AtlasCore

private actor ScriptedAtlasStreamSource: AtlasAiStreamSource {
    private var scripts: [[AtlasAiStreamFrame]]
    private var afterValues: [Int] = []

    init(_ scripts: [[AtlasAiStreamFrame]]) {
        self.scripts = scripts
    }

    func openInteractionStreamOnce(
        traceId: String,
        after: Int,
        timeoutSeconds: Int
    ) async throws -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
        afterValues.append(after)
        let frames = scripts.isEmpty ? [] : scripts.removeFirst()
        return AsyncThrowingStream { continuation in
            for frame in frames { continuation.yield(frame) }
            continuation.finish()
        }
    }

    func requestedAfters() -> [Int] { afterValues }
}

private actor ScriptedInteractionTransport: AtlasInteractionTransport {
    private let created: AiTraceResponse
    private let frames: [AtlasAiStreamFrame]?
    private var heldContinuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation?
    private var cancelledJobs: [String] = []
    private var requestedTimeouts: [Int] = []

    init(created: AiTraceResponse, frames: [AtlasAiStreamFrame]?) {
        self.created = created
        self.frames = frames
    }

    func createInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse {
        created
    }

    func interactionSnapshot(traceId: String) async throws -> AiTraceResponse {
        created
    }

    func findInteraction(clientId: String) async throws -> AiTraceResponse? { nil }

    func cancelInteractionJob(_ jobId: String) async {
        cancelledJobs.append(jobId)
        heldContinuation?.finish()
        heldContinuation = nil
    }

    func openInteractionStreamOnce(
        traceId: String,
        after: Int,
        timeoutSeconds: Int
    ) async throws -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
        requestedTimeouts.append(timeoutSeconds)
        let frames = self.frames
        return AsyncThrowingStream { continuation in
            if let frames {
                for frame in frames { continuation.yield(frame) }
                continuation.finish()
            } else {
                Task { self.hold(continuation) }
            }
        }
    }

    func cancelledJobIds() -> [String] { cancelledJobs }
    func streamTimeouts() -> [Int] { requestedTimeouts }

    private func hold(_ continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation) {
        heldContinuation = continuation
    }
}

private actor LostCreateResponseTransport: AtlasInteractionTransport {
    private let recovered: AiTraceResponse
    private var recoveryClientIds: [String] = []

    init(recovered: AiTraceResponse) { self.recovered = recovered }

    func createInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse {
        throw URLError(.networkConnectionLost)
    }

    func interactionSnapshot(traceId: String) async throws -> AiTraceResponse { recovered }

    func findInteraction(clientId: String) async throws -> AiTraceResponse? {
        recoveryClientIds.append(clientId)
        return recovered
    }

    func cancelInteractionJob(_ jobId: String) async {}

    func openInteractionStreamOnce(
        traceId: String,
        after: Int,
        timeoutSeconds: Int
    ) async throws -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(.done(AtlasAiStreamDone(
                traceId: recovered.trace.id,
                status: "succeeded",
                lastSequence: 0
            )))
            continuation.finish()
        }
    }

    func requestedRecoveryClientIds() -> [String] { recoveryClientIds }
}

private actor TerminalCreateFailureTransport: AtlasInteractionTransport {
    func createInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse {
        throw AtlasApiError(status: 422, path: "/ai/interactions", message: "invalid")
    }
    func findInteraction(clientId: String) async throws -> AiTraceResponse? { nil }
    func interactionSnapshot(traceId: String) async throws -> AiTraceResponse {
        throw AtlasApiError(status: 404, path: "/ai/interactions", message: "missing")
    }
    func cancelInteractionJob(_ jobId: String) async {}
    func openInteractionStreamOnce(
        traceId: String, after: Int, timeoutSeconds: Int
    ) async throws -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
        AsyncThrowingStream { $0.finish() }
    }
}

private func interactionResponse(
    jobStatus: String = "processing",
    toolExitCode: Int = 0
) throws -> AiTraceResponse {
    let json = """
    {
      "trace": {
        "id":"trace-run","trace_key":"trace-key","thread_id":"thread-1",
        "session_id":null,"status":"processing","operator_input":"oi",
        "intent":null,"agent_slug":"atlas","provider":"claude_cli","model":null,
        "response_text":null,"latency_ms":null,"completed_at":null,"metadata":{},
        "jobs":[{
          "id":"job-active","trace_id":"trace-run","client_id":null,
          "kind":"interaction","status":"\(jobStatus)","priority":0,
          "agent_slug":"atlas","provider":"claude_cli","model":null,
          "input_text":"oi","context_refs":[],"payload":{},
          "result_text":null,"result_json":{},"error_code":null,"error_message":null,
          "available_at":null,"reserved_at":null,"started_at":null,"finished_at":null,
          "attempts":0,"max_attempts":3,"timeout_seconds":120,"worker_id":null,
          "metadata":{},"created_at":"2026-07-12T10:00:00Z","updated_at":"2026-07-12T10:00:00Z"
        }],
        "atlas_decide_execution":null,
        "decision_receipt":{
          "schema_version":1,"trace_id":"trace-run","decision_mode":"atlas_decide",
          "selected_provider":"claude_cli","selected_model":"claude-sonnet-4-6",
          "was_overridden":false,"reason":"melhor aderência à tarefa"
        },
        "quality_evaluation":{
          "id":"quality-1","trace_id":"trace-run","thread_id":"thread-1","session_id":null,
          "provider":"claude_cli","model":"claude-sonnet-4-6","agent_slug":"atlas",
          "evaluator_version":"v3","score":0.91,"status":"passed","dimensions":{},
          "flags":[],"suggested_actions":[],"metadata":{},"actions":[],
          "created_at":"2026-07-12T10:00:00Z","updated_at":"2026-07-12T10:00:00Z"
        },
        "quality_actions":[],
        "tool_events":[{
          "id":"tool-1","event_key":"tool:key","trace_id":"trace-run","session_id":null,
          "thread_id":"thread-1","tool":"apply_patch","risk":"low",
          "permission_status":"allowed","approval_source":"policy","input_summary":{},
          "output_summary":{},"changed_files":["Sources/A.swift"],"checkpoint_id":null,
          "exit_code":\(toolExitCode),"duration_ms":42,"error":null,"created_at":"2026-07-12T10:00:00Z"
        }],
        "created_at":"2026-07-12T10:00:00Z","updated_at":"2026-07-12T10:00:00Z"
      }
    }
    """
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    return try decoder.decode(AiTraceResponse.self, from: Data(json.utf8))
}

private func streamEvent(traceId: String, sequence: Int, content: String) -> AtlasAiStreamFrame {
    .event(AtlasAiStreamEvent(
        id: nil,
        traceId: traceId,
        jobId: nil,
        attemptId: nil,
        sequence: sequence,
        type: "token",
        channel: "assistant",
        content: content,
        metadata: JSONObject(),
        occurredAt: nil
    ))
}

public func runInteractionRunChecks(_ check: (String, Bool) -> Void) async {
    print("\nAtlas AI · resumable stream (C1):")

    let source = ScriptedAtlasStreamSource([
        [streamEvent(traceId: "trace-r", sequence: 8, content: "A")],
        [
            streamEvent(traceId: "trace-r", sequence: 8, content: "DUP"),
            streamEvent(traceId: "trace-r", sequence: 9, content: "B"),
            .done(AtlasAiStreamDone(traceId: "trace-r", status: "succeeded", lastSequence: 9)),
        ],
    ])
    let stream = makeAtlasResumableInteractionStream(
        source: source,
        traceId: "trace-r",
        after: 7,
        policy: AtlasStreamReconnectPolicy(maxReconnects: 4, baseDelayMilliseconds: 0)
    )

    var contents: [String] = []
    var done = false
    do {
        for try await frame in stream {
            switch frame {
            case .event(let event): contents.append(event.content)
            case .done: done = true
            default: break
            }
        }
        check("reconnect retoma com after=lastSequence", await source.requestedAfters() == [7, 8])
        check("reconnect não duplica sequência já entregue", contents == ["A", "B"])
        check("done encerra sem nova conexão", done)
    } catch {
        check("resumable stream não deveria falhar", false)
    }

    let exhaustedSource = ScriptedAtlasStreamSource([[], [], []])
    let exhaustedStream = makeAtlasResumableInteractionStream(
        source: exhaustedSource,
        traceId: "trace-exhausted",
        after: 3,
        policy: AtlasStreamReconnectPolicy(maxReconnects: 2, baseDelayMilliseconds: 0)
    )
    do {
        for try await _ in exhaustedStream {}
        check("reconnect esgotado falha em vez de fingir conclusão", false)
    } catch is AtlasInteractionStreamError {
        check("maxReconnects limita tentativas totais", await exhaustedSource.requestedAfters() == [3, 3, 3])
        check("reconnect esgotado produz erro tipado", true)
    } catch {
        check("reconnect esgotado produz erro tipado", false)
    }

    do {
        let response = try interactionResponse()
        let transport = ScriptedInteractionTransport(
            created: response,
            frames: [
                streamEvent(traceId: "trace-run", sequence: 1, content: "Olá"),
                .done(AtlasAiStreamDone(traceId: "trace-run", status: "succeeded", lastSequence: 1)),
            ]
        )
        let run = InteractionRun(
            transport: transport,
            reconnectPolicy: AtlasStreamReconnectPolicy(maxReconnects: 0, baseDelayMilliseconds: 0),
            pollIntervalNanoseconds: 60_000_000_000
        )
        var sawCreated = false
        var content = ""
        var sawCompleted = false
        for try await event in await run.start(input: CreateAiInteractionInput(inputText: "oi")) {
            switch event {
            case .created: sawCreated = true
            case .content(let frame): content += frame.content
            case .completed: sawCompleted = true
            default: break
            }
        }
        check("InteractionRun possui create → stream → done", sawCreated && content == "Olá" && sawCompleted)
        check("InteractionRun usa janela SSE longa para agentes reais",
              await transport.streamTimeouts() == [120])
    } catch {
        check("InteractionRun lifecycle não deveria falhar", false)
    }

    do {
        let response = try interactionResponse()
        let transport = ScriptedInteractionTransport(created: response, frames: nil)
        let run = InteractionRun(
            transport: transport,
            reconnectPolicy: AtlasStreamReconnectPolicy(maxReconnects: 0, baseDelayMilliseconds: 0),
            pollIntervalNanoseconds: 60_000_000_000
        )
        let events = await run.start(input: CreateAiInteractionInput(inputText: "cancelar"))
        var iterator = events.makeAsyncIterator()
        let first = try await iterator.next()
        await run.cancel()
        let end = try await iterator.next()
        let createdFirst: Bool
        switch first {
        case .some(.created): createdFirst = true
        default: createdFirst = false
        }
        check("InteractionRun emite created antes do stream", createdFirst)
        check("cancel encerra o stream consumidor", end == nil)
        check("cancel remoto atinge jobs ativos", await transport.cancelledJobIds() == ["job-active"])
    } catch {
        check("InteractionRun cancel não deveria falhar", false)
    }

    do {
        let response = try interactionResponse(jobStatus: "succeeded")
        let transport = LostCreateResponseTransport(recovered: response)
        let outboxURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("interaction-run-success-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: outboxURL) }
        let outbox = InteractionOutbox(fileURL: outboxURL)
        let run = InteractionRun(
            transport: transport,
            reconnectPolicy: AtlasStreamReconnectPolicy(maxReconnects: 0, baseDelayMilliseconds: 0),
            pollIntervalNanoseconds: 60_000_000_000,
            outbox: outbox
        )
        let clientId = "f1bdc4b4-daa2-4f27-91bc-a4702307b553"
        var completed = false
        for try await event in await run.start(input: CreateAiInteractionInput(
            inputText: "boa noite",
            clientId: clientId
        )) {
            if case .completed = event { completed = true }
        }
        check("-1005 recupera create aceito via clientId", completed)
        check("recovery consulta exatamente o clientId estável", await transport.requestedRecoveryClientIds() == [clientId])
        check("done remove turno da outbox", await outbox.pending().isEmpty)
    } catch {
        check("-1005 recupera create aceito via clientId", false)
    }

    do {
        let outboxURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("interaction-run-terminal-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: outboxURL) }
        let outbox = InteractionOutbox(fileURL: outboxURL)
        let run = InteractionRun(transport: TerminalCreateFailureTransport(), outbox: outbox)
        do {
            for try await _ in await run.start(input: CreateAiInteractionInput(inputText: "inválido")) {}
        } catch {}
        check("422 terminal não fica em loop na outbox", await outbox.pending().isEmpty)
    }

    check("shouldKeep mantém erro de rede", shouldKeepInteraction(after: URLError(.networkConnectionLost)))
    let safeStreamError = String(describing: AtlasInteractionStreamError.reconnectsExhausted(
        traceId: "internal-secret-trace", lastSequence: 12
    ))
    check("erro público de reconnect não expõe trace interno",
          !safeStreamError.contains("internal-secret-trace"))
    check("shouldKeep mantém 408/429/5xx",
          shouldKeepInteraction(after: AtlasApiError(status: 408, path: "/ai/interactions", message: "timeout")) &&
          shouldKeepInteraction(after: AtlasApiError(status: 429, path: "/ai/interactions", message: "rate")) &&
          shouldKeepInteraction(after: AtlasApiError(status: 503, path: "/ai/interactions", message: "down")))
    check("shouldKeep descarta 4xx terminal",
          !shouldKeepInteraction(after: AtlasApiError(status: 422, path: "/ai/interactions", message: "invalid")))
    check("falha tipada distingue offline/timeout/recusada",
          atlasNetworkFailureKind(for: URLError(.notConnectedToInternet)) == .offline &&
          atlasNetworkFailureKind(for: URLError(.timedOut)) == .timedOut &&
          atlasNetworkFailureKind(for: URLError(.cannotConnectToHost)) == .connectionRefused)
    check("falha tipada distingue auth/servidor",
          atlasNetworkFailureKind(for: AtlasApiError(status: 401, path: "/", message: "")) == .unauthorized &&
          atlasNetworkFailureKind(for: AtlasApiError(status: 503, path: "/", message: "")) == .serverUnavailable)

    let planning = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 21, type: "lifecycle", content: "",
        metadata: JSONObject(["checkpoint": .string("plan"), "outcome": .string("done")])
    )
    let command = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 22, type: "lifecycle", content: "",
        metadata: JSONObject([
            "name": .string("process_started"),
            "command": .array([.string("swift"), .string("test")]),
        ])
    )
    let thinking = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 23, type: "token", channel: "assistant",
        content: "conteúdo interno que não pode aparecer",
        metadata: JSONObject(["checkpoint": .string("provider_thinking")])
    )
    check("activity tipa checkpoint de planejamento",
          atlasAgentActivity(from: planning)?.kind == .planning)
    check("processo do provider não finge ser ferramenta do agente",
          atlasAgentActivity(from: command)?.title == "Iniciando o agente" &&
          atlasAgentActivity(from: command)?.detail == nil)
    check("activity de raciocínio não vaza conteúdo interno",
          atlasAgentActivity(from: thinking)?.detail == nil &&
          atlasAgentActivity(from: thinking)?.kind == .reasoning)
    let stdout = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 24, type: "stdout", channel: "stdout", content: "x"
    )
    check("stdout cru não vira ruído no cockpit",
          atlasAgentActivity(from: stdout) == nil)

    let currentToolResource = """
    {
      "id":"tool-current","trace_id":"trace-run","tool":"bash","kind":"bash",
      "permission_status":"allowed","approval_source":"policy",
      "input_summary":{},"output_summary":{},"changed_files":[],
      "exit_code":0,"duration_ms":42,"error":null,
      "occurred_at":"2026-07-12T10:00:01Z"
    }
    """
    let currentToolDecoder = JSONDecoder()
    currentToolDecoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    let currentTool = try? currentToolDecoder.decode(
        AtlasAiToolEvent.self,
        from: Data(currentToolResource.utf8)
    )
    check("tool receipt atual do servidor decodifica sem campos legados",
          currentTool?.kind == "bash" && currentTool?.occurredAt == "2026-07-12T10:00:01Z")

    let secretCommand = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 25, type: "lifecycle", content: "",
        metadata: JSONObject([
            "name": .string("process_started"),
            "command": .array([
                .string("curl"), .string("-H"),
                .string("Authorization: Bearer atlas-super-secret"),
                .string("https://atlas.test/run?api_key=also-secret"),
                .string("--token"), .string("atlas-second-secret"),
            ]),
        ])
    )
    let safeCommand = atlasAgentActivity(from: secretCommand)?.detail ?? ""
    check("processo do provider nunca expõe comando ou segredo",
          safeCommand.isEmpty)

    // Shape canônico de CodexJsonlEventParser.php no atlas-server.
    let codexShell = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 26, type: "tool", channel: "activity",
        content: "swift run AtlasCoreChecks",
        metadata: JSONObject([
            "name": .string("shell"), "phase": .string("item.started"),
            "item_id": .string("internal-item-id"),
        ])
    )
    let codexEdit = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 27, type: "tool", channel: "activity",
        content: "/private/workspace/Sources/AtlasCore/A.swift",
        metadata: JSONObject([
            "name": .string("edit"), "phase": .string("item.completed"),
        ])
    )
    let codexShellCompleted = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 31, type: "tool", channel: "activity",
        content: "swift run AtlasCoreChecks",
        metadata: JSONObject([
            "name": .string("shell"), "phase": .string("item.completed"),
            "item_id": .string("internal-item-id"), "exit_code": .number(0),
            "status": .string("completed"),
        ])
    )
    let codexSearch = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 28, type: "tool", channel: "activity",
        content: "AtlasAgentActivity",
        metadata: JSONObject(["name": .string("search")])
    )
    let codexSecretShell = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 29, type: "tool", channel: "activity",
        content: "curl --token atlas-codex-secret https://atlas.test",
        metadata: JSONObject([
            "name": .string("shell"), "phase": .string("item.started"),
        ])
    )
    let codexThinking = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 30, type: "thinking", channel: "activity",
        content: "private chain of thought",
        metadata: JSONObject([
            "name": .string("reasoning"), "phase": .string("item.completed"),
        ])
    )
    // Shape efetivamente persistido hoje: AiStreamRecorder converte tipos do
    // parser fora de sua allowlist (`tool`/`thinking`) para `progress`, mas
    // preserva name/phase/item_id. O mobile precisa sobreviver a esse drift
    // sem perder a ferramenta nem duplicar started→completed no replay.
    let recordedShell = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 32, type: "progress", channel: "activity",
        content: "swift run AtlasCoreChecks",
        metadata: JSONObject([
            "name": .string("shell"), "phase": .string("item.started"),
            "item_id": .string("recorded-shell-item"),
        ])
    )
    let recordedShellCompleted = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 33, type: "progress", channel: "activity",
        content: "swift run AtlasCoreChecks",
        metadata: JSONObject([
            "name": .string("shell"), "phase": .string("item.completed"),
            "item_id": .string("recorded-shell-item"), "exit_code": .number(0),
            "status": .string("completed"),
        ])
    )
    let recordedThinking = AtlasAiStreamEvent(
        traceId: "trace-run", sequence: 34, type: "progress", channel: "activity",
        content: "private chain of thought",
        metadata: JSONObject([
            "name": .string("reasoning"), "phase": .string("item.completed"),
            "item_id": .string("recorded-thinking-item"),
        ])
    )
    check("tool shell Codex vira comando visível e sanitizado",
          atlasAgentActivity(from: codexShell)?.kind == .executing &&
          atlasAgentActivity(from: codexShell)?.detail == "swift run AtlasCoreChecks")
    let shellJourney = atlasAgentTimeline(from: [codexShell, codexShellCompleted])
    check("started→completed do mesmo tool vira uma linha viva",
          shellJourney.count == 1 && shellJourney.first?.kind == .completed &&
          shellJourney.first?.detail == "swift run AtlasCoreChecks")
    check("merge live substitui fase do mesmo tool sem id duplicado",
          atlasMergeAgentActivities(
              existing: [atlasAgentActivity(from: codexShell)!],
              incoming: [atlasAgentActivity(from: codexShellCompleted)!]
          ) == shellJourney)
    check("tool edit Codex vira arquivo sem caminho interno",
          atlasAgentActivity(from: codexEdit)?.kind == .editing &&
          atlasAgentActivity(from: codexEdit)?.detail == "A.swift")
    check("tool search Codex vira busca real",
          atlasAgentActivity(from: codexSearch)?.kind == .reading &&
          atlasAgentActivity(from: codexSearch)?.detail == "AtlasAgentActivity")
    check("tool shell Codex nunca vaza argumento secreto",
          atlasAgentActivity(from: codexSecretShell)?.detail == "<redacted>")
    check("thinking Codex vira atividade sem chain-of-thought",
          atlasAgentActivity(from: codexThinking)?.kind == .reasoning &&
          atlasAgentActivity(from: codexThinking)?.detail == nil)
    check("progress|shell real do ledger continua sendo comando visível",
          atlasAgentActivity(from: recordedShell)?.kind == .executing &&
          atlasAgentActivity(from: recordedShell)?.detail == "swift run AtlasCoreChecks")
    let recordedJourney = atlasAgentTimeline(from: [recordedShell, recordedShellCompleted])
    check("progress|shell persistido mantém identidade started→completed",
          recordedJourney.count == 1 && recordedJourney.first?.kind == .completed)
    check("progress|reasoning real não vaza chain-of-thought",
          atlasAgentActivity(from: recordedThinking)?.kind == .reasoning &&
          atlasAgentActivity(from: recordedThinking)?.detail == nil)

    do {
        let proofTrace = try interactionResponse().trace
        check("receipt tipado expõe escolha e razão",
              proofTrace.decisionSummary?.selectedProvider == "claude_cli" &&
              proofTrace.decisionSummary?.reason == "melhor aderência à tarefa")
        check("quality tipada expõe score/status",
              proofTrace.qualitySummary?.score == 0.91 && proofTrace.qualitySummary?.status == "passed")
        check("tool event vira atividade de edição real",
              proofTrace.toolActivities.first?.kind == .editing &&
              proofTrace.toolActivities.first?.detail == "A.swift")
        let failedToolTrace = try interactionResponse(toolExitCode: 1).trace
        check("falha de tool receipt vence sua categoria visual",
              failedToolTrace.toolActivities.first?.kind == .warning)
    } catch {
        check("projeções C5 deveriam decodificar", false)
    }
}

public func runInteractionRunLiveProbe(
    _ check: (String, Bool) -> Void,
    client: AtlasClient
) async {
    print("\nAtlas AI · InteractionRun AO VIVO (C1):")
    if let replayTrace = ProcessInfo.processInfo.environment["ATLAS_LIVE_TRACE"],
       !replayTrace.isEmpty {
        do {
            let snapshot = try await client.getAiInteraction(replayTrace)
            check("live trace decodificou receipt/decision C5", snapshot.trace.decisionSummary != nil)
            check("live trace decodificou tool/quality opcionais C5",
                  snapshot.trace.toolEvents != nil && snapshot.trace.qualityActions != nil)
            let persistedTimeline = atlasAgentTimeline(from: snapshot.trace.streamEvents ?? [])
            check("live ledger reconstrói comando executado persistente",
                  persistedTimeline.contains {
                      [.executing, .completed, .warning].contains($0.kind)
                          && $0.title.lowercased().contains("comando")
                          && $0.detail != nil
                  })
            let expectedJourney: [AtlasAgentActivity.Kind] = [
                .understanding, .context, .planning, .executing, .verifying, .evidence,
            ]
            check("live ledger cobre jornada editorial completa do cockpit",
                  expectedJourney.allSatisfy { kind in
                      persistedTimeline.contains { $0.kind == kind }
                  })
            let stream = try await client.openInteractionStreamOnce(
                traceId: replayTrace,
                after: 0,
                timeoutSeconds: 5
            )
            var events = 0
            var done = false
            for try await frame in stream {
                if case .event = frame { events += 1 }
                if case .done = frame { done = true }
            }
            check("live replay SSE decodificou eventos", events > 0)
            check("live replay SSE decodificou done", done)
        } catch {
            check("live replay SSE", false)
            print("    erro: \(error)")
        }
        return
    }
    let payload = atlasMobileInteractionPayload(base: JSONObject([
        "tool_permissions": .object(["mode": .string("read")]),
    ]))
    let input = CreateAiInteractionInput(
        inputText: "Responda somente com a palavra ATLAS.",
        clientId: UUID().uuidString.lowercased(),
        newThread: true,
        sourceType: "app",
        payload: payload
    )
    let outboxURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("atlas-live-outbox-\(UUID().uuidString).json")
    defer { try? FileManager.default.removeItem(at: outboxURL) }
    let outbox = InteractionOutbox(fileURL: outboxURL)
    let run = InteractionRun(transport: client, outbox: outbox)
    var created = false
    var createdTraceId: String?
    var receivedContent = false
    var leakedReasoning = false
    var completed = false

    do {
        for try await event in await run.start(input: input) {
            switch event {
            case .created(let trace):
                created = true
                createdTraceId = trace.id
            case .content(let frame):
                if atlasShouldRenderAssistantContent(frame) {
                    receivedContent = receivedContent || atlasVisibleAssistantText(frame.content) != nil
                }
                leakedReasoning = leakedReasoning || frame.content.lowercased().contains("┌─ reasoning")
            case .completed:
                completed = true
            case .activity, .execution, .remoteError:
                break
            }
        }
        check("live create foi aceito pelo servidor", created)
        check("live SSE entregou conteúdo", receivedContent)
        check("live Hermes não vazou Reasoning", !leakedReasoning)
        check("live SSE recebeu done", completed)
        check("live done drenou outbox", await outbox.pending().isEmpty)
        if let createdTraceId {
            let final = try await client.getAiInteraction(createdTraceId)
            check("live resposta final é apresentável",
                  final.trace.responseText.flatMap(atlasVisibleAssistantText) != nil)
            check("live snapshot preserva ledger de atividades",
                  !(final.trace.streamEvents ?? []).isEmpty)
        }
    } catch {
        check("live InteractionRun create → SSE → done", false)
        print("    erro: \(error)")
    }
}

/// Probe deliberadamente opt-in: consome uma execução Codex real para provar
/// que o contrato semântico de tool atravessa Server → SSE/ledger → Core com
/// uma janela visual mensurável. Aceita o shape canônico `tool` e o shape
/// compatível `progress|shell` enquanto o recorder do Server ainda os normaliza.
/// A tarefa é read-only e determinística; nunca escreve no workspace remoto.
public func runCodexToolActivityLiveProbe(
    _ check: (String, Bool) -> Void,
    client: AtlasClient
) async {
    print("\nAtlas AI · tool activity Codex AO VIVO (C5/U3):")
    let input = CreateAiInteractionInput(
        inputText: "Execute obrigatoriamente uma ferramenta de shell read-only com `sleep 8 && shasum -a 256 composer.json` no workspace atual. Não infira e não responda antes de executar o comando; devolva apenas o hash observado.",
        clientId: UUID().uuidString.lowercased(),
        newThread: true,
        agentSlug: "atlas",
        provider: "codex_cli",
        sourceType: "app",
        payload: atlasMobileInteractionPayload(base: JSONObject([
            "tool_permissions": .object(["mode": .string("read")]),
        ]))
    )
    let run = InteractionRun(transport: client)
    var traceId: String?
    var liveActivities: [AtlasAgentActivity] = []
    var liveToolStartedAt: Date?
    var liveToolFinishedAt: Date?
    var completed = false
    do {
        for try await event in await run.start(input: input) {
            switch event {
            case .created(let trace): traceId = trace.id
            case .activity(let activity):
                liveActivities = atlasMergeAgentActivities(
                    existing: liveActivities,
                    incoming: [activity]
                )
                if activity.title == "Executando comando",
                   activity.detail?.contains("shasum -a 256 composer.json") == true,
                   liveToolStartedAt == nil {
                    liveToolStartedAt = Date()
                }
                if activity.title == "Comando concluído",
                   activity.detail?.contains("shasum -a 256 composer.json") == true {
                    liveToolFinishedAt = Date()
                }
            case .completed: completed = true
            case .content, .execution, .remoteError: break
            }
        }
        check("live Codex tool run concluiu", completed)
        guard let traceId else {
            check("live Codex tool run criou trace", false)
            return
        }
        let snapshot = try await client.getAiInteraction(traceId)
        let toolEvents = (snapshot.trace.streamEvents ?? []).filter { event in
            event.type == "tool"
                || (event.type == "progress"
                    && event.metadata["name"]?.stringValue?.lowercased() == "shell")
        }
        let persisted = atlasAgentTimeline(from: snapshot.trace.streamEvents ?? [])
        check("live Codex persistiu tool semântico", !toolEvents.isEmpty)
        check("live Codex entregou shell.started durante execução", liveToolStartedAt != nil)
        let visibleToolSeconds = liveToolStartedAt.flatMap { started in
            liveToolFinishedAt.map { $0.timeIntervalSince(started) }
        }
        check("live Codex manteve tool observável por pelo menos 5s",
              visibleToolSeconds.map { $0 >= 5 } == true)
        check("live Codex tool reaparece no replay",
              persisted.contains {
                  [.executing, .completed, .warning].contains($0.kind)
                      && $0.detail?.contains("shasum -a 256 composer.json") == true
              })
    } catch {
        check("live Codex tool activity", false)
        print("    erro: \(error)")
    }
}
