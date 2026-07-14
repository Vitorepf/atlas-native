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
    // Contrato: o texto sai VERBATIM. O trim serve só aos guards; quem cuida do
    // espaço externo é o parser de blocos do markdown (linha em branco é pulada).
    check("resposta comum passa verbatim", atlasVisibleAssistantText("  Sim, está funcionando.  ") == "  Sim, está funcionando.  ")
    check("delta só com espaço não vira texto", atlasVisibleAssistantText("   \n ") == nil)

    // Regressão REAL vista no iPhone (2026-07-14): o stream concatena deltas em
    // `live + visible`; trimar o retorno comia o espaço de fronteira do token e
    // colava as palavras ("consigo dizer" → "consigodizer").
    let deltas = ["Não consigo", " dizer o que está", " rodando no Atlas", " agora."]
    let streamed = deltas.compactMap(atlasVisibleAssistantText).joined()
    check("streaming preserva o espaço de fronteira entre deltas",
          streamed == "Não consigo dizer o que está rodando no Atlas agora.")
    check("delta preserva espaço à esquerda", atlasVisibleAssistantText(" dizer") == " dizer")

    let payload = atlasMobileInteractionPayload(base: JSONObject(["compute_effort": .string("high")]))
    let hermes: [String: JSONValue]?
    if let value = payload["hermes"], case .object(let object) = value { hermes = object }
    else { hermes = nil }
    check("mobile força Hermes one-shot sem raciocínio", hermes?["cli_oneshot"]?.boolValue == true)
    check("mobile exige transporte Hermes estruturado", hermes?["execution_transport"]?.stringValue == "acp")
    check("política preserva payload existente", payload["compute_effort"]?.stringValue == "high")
    check("mobile se identifica como superfície interativa", payload["app_surface"]?.stringValue == "atlas_app")

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
