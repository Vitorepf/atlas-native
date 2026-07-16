import Foundation
import AtlasCore

public func runAtlasChangeReviewChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas AI · revisão de mudança vinculada ao trace (C15):")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    let available = """
    {"change_review":{"schema_version":"atlas.trace_change_review.v1","state":"available","trace_id":"tr-15",
      "run":{"status":"passed","decision":"resolved","score":100,"started_at":"2026-07-13T20:00:00Z","finished_at":"2026-07-13T20:01:00Z"},
      "patches":[{"id":"patch-1","base_ref":"base","head_ref":"head","diff_hash":"abc","changed_files":["Sources/AtlasCore/InteractionRun.swift"],"created_files":[],"deleted_files":[],"risk_flags":["networking"],"file_reviews":[{"file_path":"Sources/AtlasCore/InteractionRun.swift","action":"accept","actor":"mobile_operator","note":"Checks revisados.","decided_at":"2026-07-13T20:02:00Z"}],"created_at":"2026-07-13T20:00:00Z","diff_url":"/ai/interactions/tr-15/change-review/patches/patch-1/diff"}],
      "controls":[{"id":"control-1","slug":"swift-core-checks","status":"passed","signal_summary":"green","duration_ms":842,"created_at":"2026-07-13T20:00:00Z"}],
      "test_runs":[{"id":"test-1","command":"swift run AtlasCoreChecks","status":"passed","exit_code":0,"duration_ms":842,"created_at":"2026-07-13T20:00:00Z"}],
      "review":{"findings":[],"operator_actions":[],"available_actions":["accept","reject"]}}}
    """

    let decoded = try? decoder.decode(AtlasTraceChangeReviewResponse.self, from: Data(available.utf8))
    check("review disponível preserva o trace canônico", decoded?.changeReview.traceId == TraceID("tr-15"))
    check("review não vaza engineering_run_id", decoded?.changeReview.run?.status == "passed")
    check("patch expõe PatchID tipado", decoded?.changeReview.patches.first?.patchID == PatchID("patch-1"))
    check("patch preserva somente a rota trace-scoped do diff", decoded?.changeReview.patches.first?.diffURL == "/ai/interactions/tr-15/change-review/patches/patch-1/diff")
    check("decisão por arquivo fica ligada ao patch canônico", decoded?.changeReview.patches.first?.fileReviews.first?.filePath == "Sources/AtlasCore/InteractionRun.swift" && decoded?.changeReview.patches.first?.fileReviews.first?.action == .accept)
    check("checks e testes são recebidos como evidência real", decoded?.changeReview.controls.first?.slug == "swift-core-checks" && decoded?.changeReview.testRuns.first?.exitCode == 0)
    check("ações permitidas são somente as declaradas", decoded?.changeReview.review.availableActions == [.accept, .reject])

    let unavailable = """
    {"change_review":{"schema_version":"atlas.trace_change_review.v1","state":"unavailable","reason":"ambiguous_linked_runs","trace_id":"tr-ambiguous","patches":[],"controls":[],"test_runs":[],"review":{"findings":[],"operator_actions":[],"available_actions":[]}}}
    """
    let unavailableDecoded = try? decoder.decode(AtlasTraceChangeReviewResponse.self, from: Data(unavailable.utf8))
    check("vínculo ambíguo falha fechado no app", unavailableDecoded?.changeReview.state == .unavailable && unavailableDecoded?.changeReview.reason == "ambiguous_linked_runs" && unavailableDecoded?.changeReview.run == nil)

    let unknownSchema = available.replacingOccurrences(of: "atlas.trace_change_review.v1", with: "atlas.trace_change_review.v2")
    check("schema desconhecido não vira revisão visual inventada", (try? decoder.decode(AtlasTraceChangeReviewResponse.self, from: Data(unknownSchema.utf8))) == nil)
}
