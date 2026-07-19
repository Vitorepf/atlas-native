#if DEBUG
import Foundation

public struct AtlasArenaVisualSnapshot: Sendable {
    public let composite: AtlasArenaComposite
    public let scoreboard: AtlasArenaScoreboard
    public let report: AtlasArenaReport
    public let capabilities: AtlasArenaCapabilities
    public let engineCatalog: AtlasArenaEngines
    public let liveRuns: AtlasArenaLiveRuns
    public let plan: AtlasArenaMeasurementPlan?
}

private enum ArenaVisualScenario: String {
    case idle
    case queued
    case running
    case stopping
    case stopped
    case completed
    case failed
}

public enum AtlasArenaVisualFixture {
    public static func snapshot(scenario rawValue: String) throws -> AtlasArenaVisualSnapshot {
        guard let scenario = ArenaVisualScenario(rawValue: rawValue) else {
            throw AtlasArenaVisualFixtureError.unknownScenario
        }
        let profile = try decode(AtlasArenaCapabilities.self, json: capabilities)
        let plan = AtlasArenaMeasurementPlan(inputs: [
            AtlasArenaStartInput(
                suites: .selected([
                    "live_code_bench",
                    "swe_marathon",
                    "terminal_bench",
                    "bfcl",
                    "inspect_evals",
                ]),
                engine: "verboo_kimi_k2_7",
                arms: [.baseline, .withAtlas],
                operatorActor: "vitor",
                operatorReason: "comparar desempenho com e sem Atlas",
                origin: "iphone"
            ),
        ])
        return try AtlasArenaVisualSnapshot(
            composite: decode(AtlasArenaComposite.self, json: composite),
            scoreboard: decode(AtlasArenaScoreboard.self, json: scoreboard),
            report: decode(AtlasArenaReport.self, json: report),
            capabilities: profile,
            engineCatalog: decode(AtlasArenaEngines.self, json: engines),
            liveRuns: decode(AtlasArenaLiveRuns.self, json: liveRuns(for: scenario)),
            plan: plan
        )
    }

    static func decode<T: Decodable>(_ type: T.Type, json: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
        return try decoder.decode(T.self, from: Data(json.utf8))
    }

    static let composite = #"""
    {
      "schema_version":"atlas.arena.composite.v1",
      "generated_at":"2026-07-18T22:40:00Z",
      "suites_total":10,
      "suites_measured":10,
      "weights_public":{"live_code_bench":0.15,"swe_marathon":0.15,"terminal_bench":0.10},
      "engines":[{
        "engine":"verboo_kimi_k2_7",
        "composite":0.64,
        "previous":0.61,
        "delta":0.03,
        "with_atlas_composite":0.64,
        "without_atlas_composite":0.59,
        "atlas_multiplier":1.08,
        "coverage":1.0,
        "history":[
          {"round_at":"2026-07-15T12:00:00Z","composite":0.58,"with_atlas":0.60,"without_atlas":0.57},
          {"round_at":"2026-07-16T12:00:00Z","composite":0.61,"with_atlas":0.63,"without_atlas":0.58},
          {"round_at":"2026-07-18T22:40:00Z","composite":0.64,"with_atlas":0.64,"without_atlas":0.59}
        ]
      }]
    }
    """#

    static let scoreboard = #"""
    {
      "schema_version":"atlas.arena.scoreboard.v1",
      "generated_at":"2026-07-18T22:40:00Z",
      "suites":[
        {"suite":"live_code_bench","runs_total":12,"last_run_at":"2026-07-18T22:30:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.10,"previous_score":0.12,"delta":-0.02,"with_atlas_score":0.04,"without_atlas_score":0.10,"atlas_multiplier":0.40,"cases_passed":17,"cases_failed":25,"cases_total":42,"duration_avg_ms":74200,"regressed":true,"history":[{"round_at":"2026-07-15T12:00:00Z","score":0.12,"arm":"baseline"},{"round_at":"2026-07-16T12:00:00Z","score":0.08,"arm":"with_atlas"},{"round_at":"2026-07-18T22:30:00Z","score":0.04,"arm":"with_atlas"}]}]},
        {"suite":"swe_marathon","runs_total":8,"last_run_at":"2026-07-18T20:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.39,"previous_score":0.36,"delta":0.03,"with_atlas_score":0.42,"without_atlas_score":0.37,"atlas_multiplier":1.14,"cases_passed":14,"cases_failed":4,"cases_total":18,"duration_avg_ms":102000,"regressed":false,"history":[]}]},
        {"suite":"terminal_bench","runs_total":6,"last_run_at":"2026-07-18T19:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.62,"previous_score":0.58,"delta":0.04,"with_atlas_score":0.67,"without_atlas_score":0.57,"atlas_multiplier":1.18,"cases_passed":4,"cases_failed":2,"cases_total":6,"duration_avg_ms":88000,"regressed":false,"history":[]}]},
        {"suite":"bfcl","runs_total":18,"last_run_at":"2026-07-18T18:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.62,"previous_score":0.61,"delta":0.01,"with_atlas_score":0.66,"without_atlas_score":0.58,"atlas_multiplier":1.14,"cases_passed":12,"cases_failed":6,"cases_total":18,"duration_avg_ms":45000,"regressed":false,"history":[]}]},
        {"suite":"inspect_evals","runs_total":9,"last_run_at":"2026-07-18T17:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":1.00,"previous_score":1.00,"delta":0.00,"with_atlas_score":1.00,"without_atlas_score":1.00,"atlas_multiplier":1.00,"cases_passed":9,"cases_failed":0,"cases_total":9,"duration_avg_ms":28000,"regressed":false,"history":[]}]},
        {"suite":"tau2_bench","runs_total":9,"last_run_at":"2026-07-18T16:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.72,"previous_score":0.70,"delta":0.02,"with_atlas_score":0.74,"without_atlas_score":0.70,"atlas_multiplier":1.06,"cases_passed":7,"cases_failed":2,"cases_total":9,"duration_avg_ms":56000,"regressed":false,"history":[]}]},
        {"suite":"senior_swe_bench","runs_total":18,"last_run_at":"2026-07-18T15:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.71,"previous_score":0.69,"delta":0.02,"with_atlas_score":0.75,"without_atlas_score":0.67,"atlas_multiplier":1.12,"cases_passed":13,"cases_failed":5,"cases_total":18,"duration_avg_ms":112000,"regressed":false,"history":[]}]},
        {"suite":"swe_bench_live","runs_total":18,"last_run_at":"2026-07-18T14:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.68,"previous_score":0.70,"delta":-0.02,"with_atlas_score":0.64,"without_atlas_score":0.72,"atlas_multiplier":0.89,"cases_passed":12,"cases_failed":6,"cases_total":18,"duration_avg_ms":138000,"regressed":true,"history":[]}]},
        {"suite":"hal_harness","runs_total":18,"last_run_at":"2026-07-18T13:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.54,"previous_score":0.52,"delta":0.02,"with_atlas_score":0.58,"without_atlas_score":0.50,"atlas_multiplier":1.16,"cases_passed":10,"cases_failed":8,"cases_total":18,"duration_avg_ms":160000,"regressed":false,"history":[]}]},
        {"suite":"aider_polyglot","runs_total":42,"last_run_at":"2026-07-18T12:10:00Z","adapter_installed":true,
         "engines":[{"engine":"verboo_kimi_k2_7","score":0.74,"previous_score":0.71,"delta":0.03,"with_atlas_score":0.78,"without_atlas_score":0.70,"atlas_multiplier":1.11,"cases_passed":31,"cases_failed":11,"cases_total":42,"duration_avg_ms":95000,"regressed":false,"history":[]}]}
      ]
    }
    """#

    static let capabilities = #"""
    {
      "schema_version":"atlas.arena.capabilities.v2",
      "mapping_version":"2026-07-18",
      "engine":"verboo_kimi_k2_7",
      "capabilities":[
        {"capability":"agentic_dialogue","label_pt":"Diálogo agêntico","score":0.62,"with_atlas":0.70,"baseline_ci":[0.30,0.86],"with_atlas_ci":[0.38,0.90],"baseline_cases":9,"with_atlas_cases":9,"delta":{"value":0.08,"ci_low":-0.28,"ci_high":0.42,"significant":false},"confidence":"low","suites_contributing":["tau2_bench"],"cases_total":9,"min_cases_for_confidence":10},
        {"capability":"bug_fixing","label_pt":"Correção de bugs","score":0.68,"with_atlas":0.72,"baseline_ci":[0.52,0.81],"with_atlas_ci":[0.56,0.84],"baseline_cases":36,"with_atlas_cases":36,"delta":{"value":0.04,"ci_low":-0.16,"ci_high":0.24,"significant":false},"confidence":"measured","suites_contributing":["senior_swe_bench","swe_bench_live"],"cases_total":36,"min_cases_for_confidence":10},
        {"capability":"code_editing","label_pt":"Edição de código","score":0.10,"with_atlas":0.04,"baseline_ci":[0.05,0.18],"with_atlas_ci":[0.01,0.11],"baseline_cases":84,"with_atlas_cases":84,"delta":{"value":-0.06,"ci_low":-0.13,"ci_high":-0.01,"significant":true},"confidence":"measured","suites_contributing":["live_code_bench","aider_polyglot"],"cases_total":84,"min_cases_for_confidence":10},
        {"capability":"context_recovery","label_pt":"Recuperação de contexto","score":0.56,"with_atlas":0.71,"baseline_ci":[0.27,0.81],"with_atlas_ci":[0.39,0.91],"baseline_cases":9,"with_atlas_cases":9,"delta":{"value":0.15,"ci_low":-0.22,"ci_high":0.48,"significant":false},"confidence":"low","suites_contributing":["inspect_evals"],"cases_total":9,"min_cases_for_confidence":10},
        {"capability":"instruction_following","label_pt":"Seguir instruções","score":0.76,"with_atlas":null,"baseline_ci":[0.45,0.92],"with_atlas_ci":null,"baseline_cases":9,"with_atlas_cases":0,"delta":null,"confidence":"unmeasured","suites_contributing":["inspect_evals"],"cases_total":9,"min_cases_for_confidence":10},
        {"capability":"long_horizon","label_pt":"Trabalho de longo prazo","score":0.39,"with_atlas":0.42,"baseline_ci":[0.25,0.55],"with_atlas_ci":[0.27,0.58],"baseline_cases":36,"with_atlas_cases":36,"delta":{"value":0.03,"ci_low":-0.20,"ci_high":0.26,"significant":false},"confidence":"measured","suites_contributing":["hal_harness","swe_marathon"],"cases_total":36,"min_cases_for_confidence":10},
        {"capability":"reasoning","label_pt":"Raciocínio","score":0.65,"with_atlas":0.72,"baseline_ci":[0.51,0.77],"with_atlas_ci":[0.58,0.83],"baseline_cases":51,"with_atlas_cases":51,"delta":{"value":0.07,"ci_low":0.01,"ci_high":0.13,"significant":true},"confidence":"measured","suites_contributing":["inspect_evals","live_code_bench"],"cases_total":51,"min_cases_for_confidence":10},
        {"capability":"defensive_security","label_pt":"Segurança defensiva","score":0.74,"with_atlas":0.78,"baseline_ci":[0.43,0.91],"with_atlas_ci":[0.47,0.94],"baseline_cases":9,"with_atlas_cases":9,"delta":{"value":0.04,"ci_low":-0.32,"ci_high":0.38,"significant":false},"confidence":"low","suites_contributing":["inspect_evals"],"cases_total":9,"min_cases_for_confidence":10},
        {"capability":"terminal_operation","label_pt":"Operação de terminal","score":0.58,"with_atlas":0.67,"baseline_ci":[0.23,0.86],"with_atlas_ci":[0.30,0.90],"baseline_cases":6,"with_atlas_cases":6,"delta":{"value":0.09,"ci_low":-0.35,"ci_high":0.49,"significant":false},"confidence":"low","suites_contributing":["terminal_bench"],"cases_total":6,"min_cases_for_confidence":10},
        {"capability":"tool_use","label_pt":"Uso de ferramentas","score":0.62,"with_atlas":0.66,"baseline_ci":[0.44,0.77],"with_atlas_ci":[0.47,0.81],"baseline_cases":27,"with_atlas_cases":27,"delta":{"value":0.04,"ci_low":-0.21,"ci_high":0.29,"significant":false},"confidence":"measured","suites_contributing":["bfcl","tau2_bench"],"cases_total":27,"min_cases_for_confidence":10}
      ]
    }
    """#

    static let report = #"""
    {
      "schema_version":"atlas.arena.report.v1",
      "built_at":"2026-07-18T22:40:00Z",
      "claim_allowed":false,
      "claim_blockers":["suite_failed"],
      "narrative":"Atlas melhora o perfil geral, mas a regressão em edição de código ainda bloqueia uma afirmação final.",
      "primary_engine":"verboo_kimi_k2_7",
      "suites_ok":8,
      "suites_failed":1,
      "suites_blocked":0,
      "suites_missing_data":1,
      "suites":[
        {"suite":"live_code_bench","status":"failed","success_rate":0.10,"intelligence_rate":0.04,"median_wall_ms":74200,"cost_per_task":0.018,"env_failure_rate":0.00,"pipeline_valid":true},
        {"suite":"swe_marathon","status":"ok","success_rate":0.39,"intelligence_rate":0.42,"median_wall_ms":102000,"cost_per_task":0.031,"env_failure_rate":0.00,"pipeline_valid":true},
        {"suite":"terminal_bench","status":"ok","success_rate":0.62,"intelligence_rate":0.67,"median_wall_ms":88000,"cost_per_task":0.022,"env_failure_rate":0.00,"pipeline_valid":true}
      ],
      "engines":[{
        "engine":"verboo_kimi_k2_7",
        "runtimes_measured":["openai-api"],
        "narrative":"Melhor uso de ferramentas e recuperação de contexto; edição de código exige atenção.",
        "strengths":[{"suite":"terminal_bench","category":"tool_use","success_rate":0.67}],
        "weaknesses":[{"suite":"live_code_bench","category":"code_editing","success_rate":0.04}]
      }]
    }
    """#

    static let engines = #"""
    {
      "schema_version":"atlas.arena.engines.v1",
      "generated_at":"2026-07-18T22:40:00Z",
      "engines":[
        {"engine":"verboo_kimi_k2_7","access_type":"api","local":false},
        {"engine":"codex_gpt_5_5","access_type":"cli","local":true},
        {"engine":"claude_opus_4_8","access_type":"cli","local":true}
      ]
    }
    """#

    private static func liveRuns(for scenario: ArenaVisualScenario) -> String {
        let runs: String
        switch scenario {
        case .idle:
            runs = "[]"
        case .running:
            runs = """
            [
              \(run(id: "run_live", suite: "live_code_bench", arm: "with_atlas", status: "running", done: 17, total: 42, canStop: true)),
              \(run(id: "run_next", suite: "swe_marathon", arm: "baseline", status: "queued", done: nil, total: 18, canStop: true)),
              \(run(id: "run_after", suite: "terminal_bench", arm: "baseline", status: "queued", done: nil, total: 6, canStop: true))
            ]
            """
        case .queued:
            runs = """
            [
              \(run(id: "run_q1", suite: "live_code_bench", arm: "baseline", status: "queued", done: nil, total: 42, canStop: true)),
              \(run(id: "run_q2", suite: "live_code_bench", arm: "with_atlas", status: "queued", done: nil, total: 42, canStop: true)),
              \(run(id: "run_q3", suite: "swe_marathon", arm: "baseline", status: "queued", done: nil, total: 18, canStop: true)),
              \(run(id: "run_q4", suite: "swe_marathon", arm: "with_atlas", status: "queued", done: nil, total: 18, canStop: true)),
              \(run(id: "run_q5", suite: "terminal_bench", arm: "baseline", status: "queued", done: nil, total: 6, canStop: true))
            ]
            """
        case .stopping:
            runs = "[\(run(id: "run_stop", suite: "live_code_bench", arm: "with_atlas", status: "stopping", done: 18, total: 42, canStop: false))]"
        case .stopped:
            runs = "[\(run(id: "run_stopped", suite: "live_code_bench", arm: "with_atlas", status: "stopped", done: 18, total: 42, canStop: false))]"
        case .completed:
            runs = "[\(run(id: "run_done", suite: "live_code_bench", arm: "with_atlas", status: "completed", done: 42, total: 42, canStop: false))]"
        case .failed:
            runs = "[\(run(id: "run_failed", suite: "live_code_bench", arm: "with_atlas", status: "failed", done: 23, total: 42, canStop: false, failure: "native_execution_failed"))]"
        }
        return """
        {"schema_version":"atlas.arena.runs_live.v1","generated_at":"2026-07-18T22:40:00Z","runs":\(runs)}
        """
    }

    private static func run(
        id: String,
        suite: String,
        arm: String,
        status: String,
        done: Int?,
        total: Int?,
        canStop: Bool,
        failure: String? = nil
    ) -> String {
        let doneValue = done.map(String.init) ?? "null"
        let totalValue = total.map(String.init) ?? "null"
        let failureValue = failure.map { "\"\($0)\"" } ?? "null"
        return """
        {"run_id_public":"\(id)","measurement_id_public":"am_visual_proof","suite":"\(suite)","engine":"verboo_kimi_k2_7","arm":"\(arm)","status":"\(status)","cases_done":\(doneValue),"cases_total":\(totalValue),"started_at":"2026-07-18T22:20:00Z","queued_at":"2026-07-18T22:10:00Z","completed_at":null,"stop_requested_at":null,"stopped_at":null,"failure_code":\(failureValue),"terminal_receipt_hash":null,"can_stop":\(canStop),"origin":"iphone"}
        """
    }
}

public enum AtlasArenaVisualFixtureError: Error {
    case unknownScenario
}
#endif
