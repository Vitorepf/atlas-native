import Foundation
import AtlasCore

/// C18/C19/C21 — as três provas que o servidor emite e a casca precisa ler
/// sem inventar nada. Ausência é nil; divergência é fato derivado de status/hash.
public func runAtlasTraceGovernanceChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "diff_stats": {"files_touched": 3, "lines_added": 48, "lines_removed": 12},
      "plan_revisions": [
        {"revision": 1, "iteration": 1, "reason": "quality_gate_requested_repair", "archived_at": "2026-07-14T14:00:00-03:00",
         "plan":{"steps":[{"id":"intent","title":"Entender pedido"},{"id":"plan","title":"Planejar"}]}},
        {"revision": 2, "iteration": 2, "reason": "quality_gate_requested_repair", "archived_at": "2026-07-14T15:00:00-03:00"}
      ],
      "council_review": [
        {"provider": "claude_cli", "model": "opus", "status": "succeeded", "response_hash": "aaa", "latency_ms": 1200},
        {"provider": "codex_cli", "model": "gpt", "status": "failed", "error_code": "timeout"}
      ]
    }
    """
    let metadata = try? JSONDecoder().decode(JSONObject.self, from: Data(json.utf8))

    // C18 · o diff é medido, não estimado.
    let stats = AtlasTraceGovernance.diffStats(from: metadata)
    check("C18 diff_stats decodifica o shortstat real", stats?.filesTouched == 3 && stats?.linesAdded == 48 && stats?.linesRemoved == 12)
    check("C18 vira frase humana", stats?.headline == "3 arquivos · +48 −12")
    check("C18 ausente é nil, nunca zero", AtlasTraceGovernance.diffStats(from: nil) == nil)
    let parcial = try? JSONDecoder().decode(JSONObject.self, from: Data("{\"diff_stats\":{\"files_touched\":3}}".utf8))
    check("C18 incompleto não fabrica número", AtlasTraceGovernance.diffStats(from: parcial) == nil)

    // C19 · o plano arquivado existe e é ordenado.
    let revisions = AtlasTraceGovernance.planRevisions(from: metadata)
    check("C19 plan_revisions preserva as versões", revisions.count == 2 && revisions.first?.revision == 1 && revisions.last?.revision == 2)
    check("C19 traduz o motivo sem reclassificar", revisions.first?.humanReason == "o gate de qualidade pediu reparo")
    check("C19 preserva passos arquivados quando disponíveis", revisions.first?.stepTitles == ["Entender pedido", "Planejar"])
    check("C19 sem replanejamento é lista vazia", AtlasTraceGovernance.planRevisions(from: nil).isEmpty)

    // C21 · posição por membro, sem veredito inventado.
    let council = AtlasTraceGovernance.councilReview(from: metadata)
    check("C21 council_review preserva cada membro", council.count == 2 && council.first?.provider == "claude_cli" && council.first?.latencyMs == 1200)
    check("C21 preserva falha com código real", council.last?.status == "failed" && council.last?.errorCode == "timeout" && council.last?.responseHash == nil)
    check("C21 sem conselho é lista vazia", AtlasTraceGovernance.councilReview(from: nil).isEmpty)

    // Divergência = fato derivado (status público ou hashes distintos).
    check("C21 status distinto = divergência real", AtlasTraceGovernance.councilDiverged(council) == true)
    let dois = """
    {"council_review":[
      {"provider":"claude_cli","status":"succeeded","response_hash":"aaa"},
      {"provider":"codex_cli","status":"succeeded","response_hash":"bbb"}]}
    """
    let divergentes = AtlasTraceGovernance.councilReview(from: try? JSONDecoder().decode(JSONObject.self, from: Data(dois.utf8)))
    check("C21 hashes distintos = divergência real", AtlasTraceGovernance.councilDiverged(divergentes) == true)
    let iguais = dois.replacingOccurrences(of: "bbb", with: "aaa")
    let convergentes = AtlasTraceGovernance.councilReview(from: try? JSONDecoder().decode(JSONObject.self, from: Data(iguais.utf8)))
    check("C21 hashes iguais = sem divergência", AtlasTraceGovernance.councilDiverged(convergentes) == false)
}
