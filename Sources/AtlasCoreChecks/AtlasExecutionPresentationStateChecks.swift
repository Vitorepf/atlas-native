import Foundation
import AtlasCore

public func runAtlasExecutionPresentationStateChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas AI · estados públicos da execução (Fable 5):")

    let state = AtlasExecutionPresentationState(metadata: JSONObject([
        "presentation_state": .object([
            "schema": .string("atlas.execution.presentation.v1"),
            "kind": .string("attention_required"),
            "title": .string("Confirmação necessária"),
            "detail": .string("O ambiente de produção será alterado."),
            "checkpoint": .string("apply"),
            "deadline": .string("2026-07-14T00:00:00Z"),
            "paused_at": .string("2026-07-13T20:00:00Z"),
            "actions": .array([
                .object([
                    "id": .string("allow"),
                    "title": .string("Permitir"),
                    "style": .string("primary"),
                ]),
                .object([
                    "id": .string("deny"),
                    "title": .string("Recusar"),
                    "style": .string("secondary"),
                ]),
            ]),
        ]),
    ]))

    check("estado tipado preserva uma decisão pública", state?.kind == .attentionRequired)
    check("estado tipado conserva intenção e checkpoint", state?.title == "Confirmação necessária" && state?.checkpoint == "apply")
    check("estado tipado preserva prazo declarado pelo servidor", state?.deadline == "2026-07-14T00:00:00Z")
    check("estado tipado preserva o instante canônico da pausa", state?.pausedAt == "2026-07-13T20:00:00Z")
    check("estado tipado entrega somente ações declaradas", state?.actions.map(\.id) == ["allow", "deny"])

    let pausedPresence = AtlasExecutionPresence(
        isExecuting: true,
        presentationState: state,
        currentActivity: nil
    )
    check("atenção pausa o timer da presença", pausedPresence?.timing == .paused)
    check("atenção nomeia a fase sem texto genérico", pausedPresence?.phaseTitle == "Aguardando decisão")
    check("atenção continua presente depois do stream", pausedPresence?.isOngoing == true)
    check("presença entrega o instante exato para congelar o timer", pausedPresence?.pauseTimestamp == Date(timeIntervalSince1970: 1_783_972_800))

    let timedState = AtlasExecutionPresentationState(metadata: JSONObject([
        "presentation_state": .object([
            "schema": .string("atlas.execution.presentation.v1"),
            "kind": .string("recovering"),
            "title": .string("Execução retomando"),
            "timer": .object([
                "elapsed_active_ms": .number(5000),
                "timing": .string("running"),
                "running_since": .string("2026-07-13T20:01:00Z"),
            ]),
        ]),
    ]))
    check("estado público decodifica o tempo ativo acumulado", timedState?.timer?.elapsedActiveMilliseconds == 5000)
    check("estado público conserva o marco real da retomada", timedState?.timer?.runningSince == Date(timeIntervalSince1970: 1_783_972_860))

    let contradictoryTimerState = AtlasExecutionPresentationState(metadata: JSONObject([
        "presentation_state": .object([
            "schema": .string("atlas.execution.presentation.v1"),
            "kind": .string("attention_required"),
            "title": .string("Decisão necessária"),
            "timer": .object([
                "elapsed_active_ms": .number(5000),
                "timing": .string("running"),
                "running_since": .string("2026-07-13T20:01:00Z"),
            ]),
        ]),
    ]))
    check("timer contraditório não cria presença impossível", contradictoryTimerState == nil)

    let resumedPresence = AtlasExecutionPresence(
        isExecuting: false,
        presentationState: timedState,
        currentActivity: nil
    )
    check("presença retomada expõe o relógio público sem contar a pausa", resumedPresence?.elapsedActiveMilliseconds == 5000 && resumedPresence?.runningSince == Date(timeIntervalSince1970: 1_783_972_860))

    let activity = AtlasAgentActivity(
        id: "tool-read", sequence: 1, kind: .reading,
        title: "Lendo o projeto", detail: nil, occurredAt: nil
    )
    let activePresence = AtlasExecutionPresence(
        isExecuting: true,
        presentationState: nil,
        currentActivity: activity
    )
    check("presença usa a atividade real quando não há estado especial", activePresence?.phaseTitle == "Lendo o projeto")
    check("atividade real mantém timer correndo", activePresence?.timing == .running)

    let fallbackPresence = AtlasExecutionPresence(
        isExecuting: true,
        presentationState: nil,
        currentActivity: nil
    )
    check("fallback de presença é executando, nunca pensando", fallbackPresence?.phaseTitle == "Executando")

    let unknownKind = AtlasExecutionPresentationState(metadata: JSONObject([
        "presentation_state": .object([
            "schema": .string("atlas.execution.presentation.v1"),
            "kind": .string("almost_done"),
            "title": .string("Estado não suportado"),
        ]),
    ]))
    check("kind desconhecido não vira estado visual inventado", unknownKind == nil)

    let malformedAction = AtlasExecutionPresentationState(metadata: JSONObject([
        "presentation_state": .object([
            "schema": .string("atlas.execution.presentation.v1"),
            "kind": .string("attention_required"),
            "title": .string("Decisão necessária"),
            "actions": .array([
                .object([
                    "id": .string("allow"),
                    "title": .string("Permitir"),
                    "style": .string("unsafe"),
                ]),
            ]),
        ]),
    ]))
    check("ação malformada invalida o estado inteiro", malformedAction == nil)

    let oversizedTitle = AtlasExecutionPresentationState(metadata: JSONObject([
        "presentation_state": .object([
            "schema": .string("atlas.execution.presentation.v1"),
            "kind": .string("completed"),
            "title": .string(String(repeating: "x", count: 161)),
        ]),
    ]))
    check("título fora do limite não chega à casca", oversizedTitle == nil)

    let traceJSON = """
    {"id":"tr-state","trace_key":"mobile:tr-state","thread_id":"th-1","session_id":"s-1",
     "status":"running","operator_input":"continue","intent":null,"agent_slug":"atlas",
     "provider":null,"model":null,"response_text":null,"latency_ms":null,"completed_at":null,
     "metadata":{"presentation_state":{"schema":"atlas.execution.presentation.v1","kind":"replanning","title":"Plano revisto"}},
     "jobs":[],"atlas_decide_execution":null,"router_decision":null,"atlas_decision":null,
     "decision_receipt":null,"quality_evaluation":null,"quality_actions":[],"tool_events":[],
     "stream_events":[{"id":"evt-2","trace_id":"tr-state","job_id":null,"attempt_id":null,"sequence":2,
       "event_type":"lifecycle","channel":null,"content":"","metadata":{"presentation_state":{"schema":"atlas.execution.presentation.v1","kind":"recovering","title":"Reconectando"}},"occurred_at":null}],
     "metric_summary":{},"created_at":"2026-07-13T00:00:00Z","updated_at":"2026-07-13T00:00:00Z"}
    """
    let decoder = JSONDecoder(); decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    let trace = try? decoder.decode(AtlasAiTrace.self, from: Data(traceJSON.utf8))
    check("último evento público vence snapshot antigo", trace?.executionPresentationState?.kind == .recovering)
    check("estado do ledger preserva seu título público", trace?.executionPresentationState?.title == "Reconectando")
}
