import Foundation
import AtlasCore

public func runAtlasExecutionPlanChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas AI · plano de execução público (C10):")

    let json = """
    {"id":"tr-1","trace_key":"mobile:tr-1","thread_id":"th-1","session_id":null,
     "status":"running","operator_input":"Corrija o relatório","intent":"dev",
     "agent_slug":"atlas","provider":"codex_cli","model":"gpt-5.6",
     "response_text":null,"latency_ms":null,
     "metadata":{"execution_plan":{"schema_version":1,
       "workflow":"plan_execute_test_review_summarize",
       "selected_skill":"atlas","selected_provider":"codex_cli",
       "requested_provider":null,"agents":["planner","executor","reviewer"],
       "tools_allowed":["semantic_search","repo_context","git_diff"],
       "quality_gates":["diff_summary_required","tests_or_not_run_reason_required"],
       "steps":[
         {"id":"intent","checkpoint":"intent","title":"Entender o pedido","source":"execution_plan"},
         {"id":"context","checkpoint":"context","title":"Reunir contexto","source":"execution_plan"},
         {"id":"plan","checkpoint":"plan","title":"Planejar a execução","source":"execution_plan"},
         {"id":"provider","checkpoint":"provider","title":"Executar a solicitação","source":"execution_plan"},
         {"id":"verify","checkpoint":"verify","title":"Verificar o resultado","source":"execution_plan"},
         {"id":"evidence","checkpoint":"evidence","title":"Registrar evidências","source":"execution_plan"}],
       "requires_human_confirmation":false,
       "agent_behavior_contract":{"content_hash":"nao-expor"}}},
     "jobs":[],"atlas_decide_execution":null,"router_decision":null,"atlas_decision":null,
     "decision_receipt":null,"quality_evaluation":null,"quality_actions":[],"tool_events":[],
     "stream_events":[],"metric_summary":{},"created_at":"2026-07-13T00:00:00Z",
     "updated_at":"2026-07-13T00:00:00Z"}
    """
    let decoder = JSONDecoder(); decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    let trace = try? decoder.decode(AtlasAiTrace.self, from: Data(json.utf8))
    let plan = trace?.executionPlan

    check("plano nasce apenas de execution_plan do trace", plan?.workflow == "plan_execute_test_review_summarize")
    check("plano mantém papéis reais do servidor", plan?.agents.map(\.title) == ["Planejador", "Executor", "Revisor"])
    check("plano mantém ferramentas autorizadas", plan?.tools.map(\.label) == ["Busca semântica", "Contexto do projeto", "Diferenças do Git"])
    check("plano expõe gates de qualidade", plan?.qualityGates.count == 2)
    check("plano declara seis etapas do ledger", plan?.steps.map(\.checkpoint) == ["intent", "context", "plan", "provider", "verify", "evidence"])
    check("plano não promove contador sem checkpoint real", plan?.progress(events: [], traceStatus: "queued") == nil)
    check("plano só expõe a superfície pública", plan?.agents.count == 3 && plan?.tools.count == 3)

    let events = [
        AtlasAiStreamEvent(traceId: "tr-1", sequence: 1, type: "lifecycle", content: "", metadata: JSONObject(["checkpoint": .string("intent"), "outcome": .string("done")])),
        AtlasAiStreamEvent(traceId: "tr-1", sequence: 2, type: "lifecycle", content: "", metadata: JSONObject(["checkpoint": .string("context"), "outcome": .string("done")])),
        AtlasAiStreamEvent(traceId: "tr-1", sequence: 3, type: "lifecycle", content: "", metadata: JSONObject(["checkpoint": .string("plan"), "outcome": .string("done")])),
        AtlasAiStreamEvent(traceId: "tr-1", sequence: 4, type: "lifecycle", content: "", metadata: JSONObject(["checkpoint": .string("provider"), "outcome": .string("started")])),
    ]
    let progress = plan?.progress(events: events, traceStatus: "running")
    check("progresso vem do último checkpoint real", progress?.current == 4 && progress?.total == 6 && progress?.title == "Executar a solicitação")
    check("plano sem etapas continua sem progresso", AtlasExecutionPlan(metadata: JSONObject([
        "execution_plan": .object([
            "workflow": .string("direct_answer_with_context"),
            "agents": .array([.string("atlas")]),
            "tools_allowed": .array([]),
            "quality_gates": .array([.string("answer_grounded_in_context_or_lacuna_declared")]),
        ])
    ]))?.progress(events: events, traceStatus: "running") == nil)

    let malformed = AtlasExecutionPlan(metadata: JSONObject([
        "execution_plan": .object(["workflow": .string("unknown_future_flow")])
    ]))
    check("plano incompleto não é apresentado", malformed == nil)
}
