import Foundation
import AtlasCore

public func runAssistantPresentationChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas AI · assistant presentation:")

    let stdoutChunk = AtlasAiStreamEvent(
        traceId: "trace-1", sequence: 7, type: "token", channel: "assistant",
        content: "internal reasoning", metadata: JSONObject([
            "name": .string("stdout_chunk"),
            "parser": .string("stdout_chunk"),
        ])
    )
    check("stdout_chunk nunca vira resposta visível", !atlasShouldRenderAssistantContent(stdoutChunk))
    check("stdout_chunk vira atividade segura", atlasAgentActivity(from: stdoutChunk)?.kind == .reasoning)

    let providerToken = AtlasAiStreamEvent(
        traceId: "trace-1", sequence: 8, type: "token", channel: "assistant",
        content: "Olá", metadata: JSONObject(["parser": .string("provider_token")])
    )
    check("token estruturado continua visível", atlasShouldRenderAssistantContent(providerToken))

    let leaked = """
    ┌─ Reasoning ───────────────────────────────┐
    I should expose private reasoning here.
    └───────────────────────────────────────────┘
    Resposta final
    """
    check("bloco de reasoning é rejeitado por defesa", atlasVisibleAssistantText(leaked) == nil)
    check("resposta comum é preservada", atlasVisibleAssistantText("  Sim, está funcionando.  ") == "Sim, está funcionando.")

    let payload = atlasMobileInteractionPayload(base: JSONObject(["compute_effort": .string("high")]))
    let hermes: [String: JSONValue]?
    if let value = payload["hermes"], case .object(let object) = value { hermes = object }
    else { hermes = nil }
    check("mobile força Hermes one-shot sem raciocínio", hermes?["cli_oneshot"]?.boolValue == true)
    check("política preserva payload existente", payload["compute_effort"]?.stringValue == "high")

    let ledgerJSON = """
    {"trace_id":"trace-1","sequence":1,"event_type":"lifecycle","channel":"system",
     "content":"","metadata":{"checkpoint":"intent"},"occurred_at":"2026-07-13T00:00:00Z"}
    """
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let ledgerEvent = try? decoder.decode(AtlasAiStreamEvent.self, from: Data(ledgerJSON.utf8))
    check("ledger REST decodifica event_type", ledgerEvent?.type == "lifecycle")
    check("ledger REST reconstrói atividade", ledgerEvent.flatMap(atlasAgentActivity)?.kind == .understanding)

    let stdoutChunk2 = AtlasAiStreamEvent(
        traceId: "trace-1", sequence: 9, type: "token", channel: "assistant",
        content: "more internal reasoning", metadata: JSONObject([
            "name": .string("stdout_chunk"), "parser": .string("stdout_chunk"),
        ])
    )
    check("replay colapsa chunks consecutivos equivalentes",
          atlasAgentTimeline(from: [stdoutChunk, stdoutChunk2]).count == 1)
}
