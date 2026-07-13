import Foundation

/// Política de apresentação do chat. O servidor pode transportar stdout para
/// auditoria/replay, mas stdout não é uma resposta do assistente e nunca deve
/// aparecer como texto da conversa.
public func atlasShouldRenderAssistantContent(_ event: AtlasAiStreamEvent) -> Bool {
    guard event.channel == nil || event.channel == "assistant" else { return false }
    guard event.type == "token" || event.type == "response" else { return false }
    guard !event.content.isEmpty else { return false }

    let parser = event.metadata["parser"]?.stringValue?.lowercased()
    let name = event.metadata["name"]?.stringValue?.lowercased()
    guard parser != "stdout_chunk", name != "stdout_chunk" else { return false }
    return atlasVisibleAssistantText(event.content) != nil
}

/// Defesa final contra providers CLI que acidentalmente devolvam sua interface
/// de raciocínio no campo de resposta. Não tenta adivinhar onde começa a resposta:
/// se o envelope está contaminado, rejeita tudo para jamais expor pensamento interno.
public func atlasVisibleAssistantText(_ text: String) -> String? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    let lower = trimmed.lowercased()
    let hasReasoningFrame = (trimmed.contains("┌") || trimmed.contains("╭"))
        && (lower.contains("reasoning") || lower.contains("chain of thought"))
    guard !hasReasoningFrame else { return nil }
    return trimmed
}

/// Hermes possui um modo próprio para automação (`-z`) que imprime somente a
/// resposta final. O servidor seleciona esse caminho através desta flag.
public func atlasMobileInteractionPayload(base: JSONObject = JSONObject()) -> JSONObject {
    var payload = base.values
    var hermes: [String: JSONValue]
    if case .object(let existing)? = payload["hermes"] { hermes = existing }
    else { hermes = [:] }
    hermes["cli_oneshot"] = JSONValue.bool(true)
    payload["hermes"] = JSONValue.object(hermes)
    return JSONObject(payload)
}
