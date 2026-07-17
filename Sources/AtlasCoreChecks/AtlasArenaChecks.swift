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
    {"schema_version":"atlas.arena.capabilities.v1","mapping_version":"arena.capability_map.v1",
     "engine":"codex_cli","capabilities":[{"capability":"terminal_operation","label_pt":"Operação de terminal",
       "score":0.86,"with_atlas":0.93,"suites_contributing":["terminal_bench"],"cases_total":42}]}
    """
    let capabilities = try? decoder.decode(AtlasArenaCapabilities.self, from: Data(capabilitiesJSON.utf8))
    check("capacidades decodificam barras duplas", capabilities?.capabilities.first?.score == 0.86 && capabilities?.capabilities.first?.withAtlas == 0.93)
    check("capacidade preserva suites contribuintes", capabilities?.capabilities.first?.suitesContributing == ["terminal_bench"])

    let liveJSON = """
    {"schema_version":"atlas.arena.runs_live.v1","generated_at":"2026-07-17T01:00:00Z",
     "runs":[{"run_id_public":"ar_1","suite":"terminal_bench","engine":"codex_cli",
       "arm":"with_atlas","status":"running","cases_done":17,"cases_total":42,
       "started_at":"2026-07-17T01:00:00Z"},
      {"run_id_public":"ar_2","suite":"terminal_bench","engine":"codex_cli",
       "arm":"baseline","status":"queued","queued_at":"2026-07-17T01:01:00Z"}]}
    """
    let live = try? decoder.decode(AtlasArenaLiveRuns.self, from: Data(liveJSON.utf8))
    check("AGORA decodifica running e queued", live?.runs.map(\.status) == [.running, .queued])
    check("queued tem copy honesta de fila", live?.runs.last?.status.displayPT == "na fila, ainda não iniciado")

    let receiptJSON = """
    {"schema_version":"atlas.arena.start_receipt.v1","status":"enqueued","receipt_hash":"sha256:abc",
     "runs_planned":2,"started":false,"worker_implemented":false,"provider_invoked":false,
     "note":"measurement_worker_missing_enqueue_only"}
    """
    let receipt = try? decoder.decode(AtlasArenaStartReceipt.self, from: Data(receiptJSON.utf8))
    check("recibo de start preserva fila sem iniciar execução",
          receipt?.isEnqueued == true && receipt?.started == false && receipt?.workerImplemented == false)

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

    check("rota Arena composite usa contrato público", AtlasRoute.arenaComposite == "/arena/composite")
    check("rota Arena capabilities encoda engine", AtlasRoute.arenaCapabilities(engine: "codex/cli") == "/arena/capabilities?engine=codex%2Fcli")
}
