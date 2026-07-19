import Foundation
import AtlasCore

public func runAtlasArenaChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas Arena · contratos públicos de medição:")
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    let compositeJSON = """
    {"schema_version":"atlas.arena.composite.v1","generated_at":"2026-07-17T01:00:00Z",
     "suites_total":10,"suites_measured":8,"weights_public":{"terminal_bench":0.15,"inspect_evals":0.10},
     "engines":[{"engine":"codex_cli","composite":0.83,"previous":0.79,"delta":0.04,
       "with_atlas_composite":0.92,"without_atlas_composite":0.75,"atlas_multiplier":1.23,
       "coverage":0.8,"history":[{"round_at":"2026-07-17T00:00:00Z","composite":0.79,
         "with_atlas":0.90,"without_atlas":0.73}]}]}
    """
    let composite = try? decoder.decode(AtlasArenaComposite.self, from: Data(compositeJSON.utf8))
    check("composto Arena exige schema e decodifica cobertura parcial",
          composite?.schemaVersion == AtlasArenaComposite.schemaVersion &&
          composite?.suitesMeasured == 8 &&
          composite?.engines.first?.coverage == 0.8)
    check("histórico do índice preserva braços medidos",
          composite?.engines.first?.history.first?.withAtlas == 0.90 &&
          composite?.engines.first?.history.first?.withoutAtlas == 0.73)

    let wrongComposite = compositeJSON.replacingOccurrences(
        of: "atlas.arena.composite.v1",
        with: "atlas.arena.composite.v0"
    )
    check("schema errado do composto falha fechado",
          (try? decoder.decode(AtlasArenaComposite.self, from: Data(wrongComposite.utf8))) == nil)

    let armOnlyJSON = """
    {"schema_version":"atlas.arena.composite.v1","generated_at":"2026-07-17T01:00:00Z",
     "suites_total":10,"suites_measured":1,"weights_public":{"terminal_bench":0.15},
     "engines":[{"engine":"hermes","composite":0.61,"previous":null,"delta":null,
       "with_atlas_composite":null,"without_atlas_composite":0.61,"atlas_multiplier":null,
       "coverage":0.15,"history":[{"round_at":"2026-07-17T00:00:00Z","composite":0.61}]}]}
    """
    let armOnly = try? decoder.decode(AtlasArenaComposite.self, from: Data(armOnlyJSON.utf8))
    check("braço único mantém multiplier ausente", armOnly?.engines.first?.atlasMultiplier == nil)
    check("coverage parcial não vira completo", armOnly?.engines.first?.isPartialCoverage == true)

    let scoreboardJSON = """
    {"schema_version":"atlas.arena.scoreboard.v1","generated_at":"2026-07-17T01:00:00Z",
     "suites":[{"suite":"terminal_bench","runs_total":12,"last_run_at":"2026-07-17T00:00:00Z",
       "adapter_installed":true,"engines":[{"engine":"codex_cli","score":0.81,"previous_score":0.78,
         "delta":0.03,"with_atlas_score":0.91,"without_atlas_score":0.74,"atlas_multiplier":1.23,
         "cases_passed":34,"cases_failed":8,"cases_total":42,"duration_avg_ms":48200,
         "regressed":false,"history":[{"round_at":"2026-07-17T00:00:00Z","score":0.78,"arm":"baseline"}]}]},
      {"suite":"inspect_evals","runs_total":0,"last_run_at":null,"adapter_installed":false,"engines":[]}]}
    """
    let scoreboard = try? decoder.decode(AtlasArenaScoreboard.self, from: Data(scoreboardJSON.utf8))
    check("scoreboard expõe adapter instalado por suíte",
          scoreboard?.suites.first?.adapterInstalled == true &&
          scoreboard?.suites.last?.adapterInstalled == false)
    check("não medido permanece sem score", scoreboard?.suites.last?.isMeasured == false)
    check("histórico por suíte preserva braço", scoreboard?.suites.first?.engines.first?.history.first?.arm == .baseline)

    let capabilitiesJSON = """
    {"schema_version":"atlas.arena.capabilities.v2","mapping_version":"arena.capability_map.v1",
     "engine":"codex_cli","capabilities":[{"capability":"terminal_operation","label_pt":"Operação de terminal",
       "score":0.86,"with_atlas":0.93,"baseline_ci":[0.73,0.93],"with_atlas_ci":[0.82,0.97],
       "baseline_cases":42,"with_atlas_cases":42,"delta":{"value":0.07,"ci_low":0.01,"ci_high":0.13,"significant":true},
       "confidence":"measured","suites_contributing":["terminal_bench"],"cases_total":42,"min_cases_for_confidence":10}]}
    """
    let capabilities = try? decoder.decode(AtlasArenaCapabilities.self, from: Data(capabilitiesJSON.utf8))
    check("capacidades decodificam barras duplas", capabilities?.capabilities.first?.score == 0.86 && capabilities?.capabilities.first?.withAtlas == 0.93)
    check("capacidade preserva suites contribuintes", capabilities?.capabilities.first?.suitesContributing == ["terminal_bench"])
    check("capacidade decodifica IC de Wilson por braço", capabilities?.capabilities.first?.baselineCi == [0.73, 0.93] && capabilities?.capabilities.first?.withAtlasCi == [0.82, 0.97])
    check("capacidade decodifica delta com significância", capabilities?.capabilities.first?.delta?.value == 0.07 && capabilities?.capabilities.first?.delta?.significant == true)
    check("capacidade decodifica confiança medida", capabilities?.capabilities.first?.confidenceLevel == .measured && capabilities?.capabilities.first?.withAtlasCases == 42)
    check("régua pública Arena converte score normalizado para zero a dez",
          abs((AtlasArenaPresentationScale.score(0.67) ?? 0) - 6.7) < 0.000_001 &&
          AtlasArenaPresentationScale.score(1.0) == 10.0)
    check("régua pública Arena converte delta sem alterar o sinal",
          abs((AtlasArenaPresentationScale.delta(-0.06) ?? 0) + 0.6) < 0.000_001)
    check("régua pública Arena preserva ausência em vez de fabricar zero",
          AtlasArenaPresentationScale.score(nil) == nil)

    let reportJSON = """
    {"schema_version":"atlas.arena.report.v1","built_at":"2026-07-17T02:00:00Z",
     "claim_allowed":false,"claim_blockers":["coverage_incomplete"],
     "narrative":"Medição parcial; faltam suítes.","primary_engine":"codex_cli",
     "suites_ok":7,"suites_failed":1,"suites_blocked":1,"suites_missing_data":1,
     "suites":[{"suite":"terminal_bench","status":"ok","success_rate":0.81,
       "intelligence_rate":0.76,"median_wall_ms":48200,"cost_per_task":0.03,
       "env_failure_rate":0.02,"pipeline_valid":true},
      {"suite":"swe_marathon","status":"not_run","success_rate":null,
       "intelligence_rate":null,"median_wall_ms":null,"cost_per_task":null,
       "env_failure_rate":null,"pipeline_valid":false},
      {"suite":"inspect_evals","status":"failed","success_rate":0.38,
       "intelligence_rate":0.31,"median_wall_ms":61000,"cost_per_task":0.05,
       "env_failure_rate":0.0,"pipeline_valid":false}],
     "engines":[{"engine":"codex_cli","runtimes_measured":["bare","atlas_dev"],
       "narrative":"Forte em terminal.",
       "strengths":[{"suite":"terminal_bench","category":"terminal_operation","success_rate":0.91}],
       "weaknesses":[{"suite":"inspect_evals","category":"context_recovery","success_rate":0.38}]}]}
    """
    let report = try? decoder.decode(AtlasArenaReport.self, from: Data(reportJSON.utf8))
    check("relatório Arena preserva confiança fail-closed e bloqueadores",
          report?.claimAllowed == false &&
          report?.claimBlockers == ["coverage_incomplete"] &&
          report?.suitesMissingData == 1)
    check("relatório Arena traz resultado de suíte sem inventar ausência",
          report?.suites.first?.successRate == 0.81 &&
          report?.suites.first?.status == .ok &&
          report?.suites.first?.pipelineValid == true &&
          report?.suites.first?.medianWallMs == 48_200)
    check("relatório Arena conta não medido a partir das linhas reais",
          report?.suitesNotRun == 1 &&
          report?.suites[1].status == .notRun)
    check("alertas separam falha real de suíte ainda não medida",
          report?.attentionSuites.map(\.suite) == ["inspect_evals"] &&
          report?.suites[1].status.requiresAttention == false)
    check("relatório Arena sustenta forças e fragilidades por motor",
          report?.engines.first?.strengths.first?.category == "terminal_operation" &&
          report?.engines.first?.weaknesses.first?.successRate == 0.38)

    let wrongReport = reportJSON.replacingOccurrences(
        of: "atlas.arena.report.v1",
        with: "atlas.arena.report.v0"
    )
    check("schema errado do relatório falha fechado",
          (try? decoder.decode(AtlasArenaReport.self, from: Data(wrongReport.utf8))) == nil)

    let liveJSON = """
    {"schema_version":"atlas.arena.runs_live.v1","generated_at":"2026-07-17T01:00:00Z",
     "runs":[{"run_id_public":"ar_1","suite":"terminal_bench","engine":"codex_cli",
       "arm":"with_atlas","status":"running","cases_done":17,"cases_total":42,
       "started_at":"2026-07-17T01:00:00Z","origin":"iphone"},
      {"run_id_public":"ar_2","suite":"terminal_bench",
       "arm":"baseline","status":"queued","queued_at":"2026-07-17T01:01:00Z"}]}
    """
    let live = try? decoder.decode(AtlasArenaLiveRuns.self, from: Data(liveJSON.utf8))
    check("AGORA decodifica running e queued", live?.runs.map(\.status) == [.running, .queued])
    check("queued tem copy honesta de fila", live?.runs.last?.status.displayPT == "na fila, ainda não iniciado")
    check("run live parcial sem motor não derruba AGORA",
          live?.runs.last?.engineDisplayName == "motor desconhecido")
    check("origem decodifica quando publicada e é fail-open quando ausente",
          live?.runs.first?.origin == "iphone" && live?.runs.last?.origin == nil)
    let livePresentation = live?.presentation
    check("projeção AGORA prioriza a execução viva sem misturar a fila",
          livePresentation?.phase == .running &&
          livePresentation?.primaryRun?.runIdPublic == "ar_1" &&
          livePresentation?.runningRuns.map(\.runIdPublic) == ["ar_1"] &&
          livePresentation?.queuedRuns.map(\.runIdPublic) == ["ar_2"])
    check("progresso AGORA só existe com denominador verdadeiro",
          livePresentation?.progress?.completed == 17 &&
          livePresentation?.progress?.total == 42 &&
          livePresentation?.progress?.remaining == 25 &&
          livePresentation?.progress?.fraction == 17.0 / 42.0)

    let mixedLiveJSON = """
    {"schema_version":"atlas.arena.runs_live.v1","generated_at":"2026-07-17T01:00:00Z",
     "runs":[{"run_id_public":"ar_failed","suite":"terminal_bench","engine":"codex_cli",
       "arm":"baseline","status":"failed","failure_code":"internal_error"},
      {"run_id_public":"ar_unknown","suite":"inspect_evals","engine":"codex_cli",
       "arm":"with_atlas","status":"paused"}]}
    """
    let mixedLive = try? decoder.decode(AtlasArenaLiveRuns.self, from: Data(mixedLiveJSON.utf8))
    check("falha e estado desconhecido nunca viram fila por exclusão",
          mixedLive?.presentation.phase == .failed &&
          mixedLive?.presentation.queuedRuns.isEmpty == true &&
          mixedLive?.presentation.unknownRuns.map(\.runIdPublic) == ["ar_unknown"])
    check("falha live decodifica somente código público allowlisted",
          mixedLive?.runs.first?.failureCode == "internal_error")

    let queuedLiveJSON = """
    {"schema_version":"atlas.arena.runs_live.v1","generated_at":"2026-07-17T01:00:00Z",
     "runs":[{"run_id_public":"ar_q1","suite":"terminal_bench","engine":"codex_cli",
       "arm":"baseline","status":"queued"},
      {"run_id_public":"ar_q2","suite":"terminal_bench","engine":"codex_cli",
       "arm":"with_atlas","status":"queued"},
      {"run_id_public":"ar_q3","suite":"inspect_evals","engine":"codex_cli",
       "arm":"baseline","status":"queued"}]}
    """
    let queuedLive = try? decoder.decode(AtlasArenaLiveRuns.self, from: Data(queuedLiveJSON.utf8))
    check("fila agrupa suítes sem duplicar braços",
          queuedLive?.presentation.phase == .queued &&
          queuedLive?.presentation.queuedSuites == ["terminal_bench", "inspect_evals"])

    let terminalLiveJSON = """
    {"schema_version":"atlas.arena.runs_live.v1","generated_at":"2026-07-17T01:00:00Z",
     "runs":[{"run_id_public":"ar_stop","measurement_id_public":"am_123",
       "suite":"terminal_bench","engine":"codex_cli","arm":"baseline",
       "status":"stopping","cases_done":17,"cases_total":42,"can_stop":false,
       "stop_requested_at":"2026-07-17T01:10:00Z"},
      {"run_id_public":"ar_done","measurement_id_public":"am_older",
       "suite":"inspect_evals","engine":"codex_cli","arm":"with_atlas",
       "status":"completed","can_stop":false,
       "completed_at":"2026-07-17T00:50:00Z","terminal_receipt_hash":"done-hash"}]}
    """
    let terminalLive = try? decoder.decode(AtlasArenaLiveRuns.self, from: Data(terminalLiveJSON.utf8))
    check("ciclo terminal decodifica identidade, stopping e recibo",
          terminalLive?.runs.first?.measurementIdPublic == "am_123" &&
          terminalLive?.runs.first?.status == .stopping &&
          terminalLive?.runs.first?.canStop == false &&
          terminalLive?.runs.last?.status == .completed &&
          terminalLive?.runs.last?.terminalReceiptHash == "done-hash")
    check("stopping vence o terminal anterior na projeção AGORA",
          terminalLive?.presentation.phase == .stopping &&
          terminalLive?.presentation.stoppingRuns.map(\.runIdPublic) == ["ar_stop"])
    let completedProgressJSON = """
    {"schema_version":"atlas.arena.runs_live.v1",
     "runs":[{"run_id_public":"ar_terminal","measurement_id_public":"am_done",
       "suite":"terminal_bench","status":"completed","cases_done":42,"cases_total":42}]}
    """
    let completedProgress = try? decoder.decode(
        AtlasArenaLiveRuns.self,
        from: Data(completedProgressJSON.utf8)
    )
    check("terminal preserva denominador verdadeiro para a prova visual",
          completedProgress?.presentation.phase == .completed &&
          completedProgress?.presentation.progress?.completed == 42 &&
          completedProgress?.presentation.progress?.total == 42)

    let enginesJSON = """
    {"schema_version":"atlas.arena.engines.v1","generated_at":"2026-07-17T01:00:00Z",
     "engines":[{"engine":"codex_gpt_5_5","access_type":"cli","local":true},
       {"engine":"glm_5_2","access_type":"api"}]}
    """
    let engineCatalog = try? decoder.decode(AtlasArenaEngines.self, from: Data(enginesJSON.utf8))
    check("catálogo de motores decodifica com campos opcionais fail-open",
          engineCatalog?.engines.map(\.engine) == ["codex_gpt_5_5", "glm_5_2"] &&
          engineCatalog?.engines.last?.local == nil)

    let receiptJSON = """
    {"schema_version":"atlas.arena.start_receipt.v1","status":"enqueued",
     "measurement_id_public":"am_123","receipt_hash":"sha256:abc",
     "runs_planned":2,"started":false,"worker_implemented":false,"provider_invoked":false,
     "note":"measurement_worker_missing_enqueue_only"}
    """
    let receipt = try? decoder.decode(AtlasArenaStartReceipt.self, from: Data(receiptJSON.utf8))
    check("recibo de start preserva fila sem iniciar execução",
          receipt?.isEnqueued == true &&
          receipt?.measurementIdPublic == "am_123" &&
          receipt?.started == false &&
          receipt?.workerImplemented == false)

    let stopReceiptJSON = """
    {"schema_version":"atlas.arena.stop_receipt.v1","measurement_id_public":"am_123",
     "status":"stopping","accepted":true,"receipt_hash":"stop-hash",
     "requested_at":"2026-07-17T01:10:00Z","queued_stopped":2,
     "running_stop_requested":1,"already_stopped":0,"stops_after_current_case":true}
    """
    let stopReceipt = try? decoder.decode(AtlasArenaStopReceipt.self, from: Data(stopReceiptJSON.utf8))
    check("recibo de Parar preserva escopo e transição honesta",
          stopReceipt?.measurementIdPublic == "am_123" &&
          stopReceipt?.status == .stopping &&
          stopReceipt?.accepted == true &&
          stopReceipt?.queuedStopped == 2 &&
          stopReceipt?.runningStopRequested == 1 &&
          stopReceipt?.stopsAfterCurrentCase == true)
    let lateStopJSON = """
    {"schema_version":"atlas.arena.stop_receipt.v1","measurement_id_public":"am_done",
     "status":"completed","accepted":false,"receipt_hash":"terminal-hash",
     "queued_stopped":0,"running_stop_requested":0,"already_stopped":0,
     "stops_after_current_case":false}
    """
    let lateStop = try? decoder.decode(AtlasArenaStopReceipt.self, from: Data(lateStopJSON.utf8))
    check("Parar tardio preserva terminal e não afirma aceite",
          lateStop?.status == .completed && lateStop?.accepted == false)

    let input = AtlasArenaStartInput(
        suites: .selected(["terminal_bench"]),
        engine: "codex_cli",
        arms: [.baseline, .withAtlas],
        operatorActor: " vitor ",
        operatorReason: " janela aprovada "
    )
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let payload = (try? JSONSerialization.jsonObject(with: encoder.encode(input))) as? [String: Any]
    check("input de start exige ator e motivo", input.isLocallyValidForSubmission)
    check("input de start envia snake_case governado",
          payload?["operator_actor"] as? String == "vitor" &&
          payload?["operator_reason"] as? String == "janela aprovada")
    let missingReason = AtlasArenaStartInput(
        suites: .selected(["terminal_bench"]),
        engine: "codex_cli",
        operatorActor: "vitor",
        operatorReason: ""
    )
    check("input sem motivo é inválido localmente", missingReason.isLocallyValidForSubmission == false)

    let secondInput = AtlasArenaStartInput(
        suites: .selected(["terminal_bench", "inspect_evals"]),
        engine: "kimi_k2_7",
        arms: [.baseline, .withAtlas],
        operatorActor: "vitor",
        operatorReason: "comparar dois motores"
    )
    let batchPlan = AtlasArenaMeasurementPlan(inputs: [input, secondInput])
    check("plano agrega motores, suítes e braços sem duplicar",
          batchPlan?.engines == ["codex_cli", "kimi_k2_7"] &&
          batchPlan?.suites == ["terminal_bench", "inspect_evals"] &&
          batchPlan?.arms == [.baseline, .withAtlas])
    check("plano conta runs pela seleção real de cada motor",
          batchPlan?.runsPlanned == 6 &&
          batchPlan?.comparesAtlas == true)
    check("plano inválido falha fechado antes da casca",
          AtlasArenaMeasurementPlan(inputs: [missingReason]) == nil)

    check("rota Arena composite usa contrato público", AtlasRoute.arenaComposite == "/arena/composite")
    check("rota Arena report usa contrato público", AtlasRoute.arenaReport == "/arena/report")
    check("rota Arena Parar encoda identidade pública",
          AtlasRoute.arenaStop(measurementId: "am/a") == "/arena/measurements/am%2Fa/stop")
    check("rota Arena capabilities encoda engine", AtlasRoute.arenaCapabilities(engine: "codex/cli") == "/arena/capabilities?engine=codex%2Fcli")
}
