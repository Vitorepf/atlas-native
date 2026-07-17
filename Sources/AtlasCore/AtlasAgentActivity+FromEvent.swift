import Foundation

/// Projeta eventos heterogêneos do servidor num vocabulário pequeno e estável.
/// `nil` significa que o evento é conteúdo de resposta ou ruído de transporte.
public func atlasAgentActivity(from event: AtlasAiStreamEvent) -> AtlasAgentActivity? {
    let metadata = event.metadata
    let name = metadata["name"]?.stringValue?.lowercased() ?? ""
    let checkpoint = metadata["checkpoint"]?.stringValue?.lowercased() ?? ""
    let outcome = metadata["outcome"]?.stringValue?.lowercased() ?? ""
    let phase = metadata["phase"]?.stringValue?.lowercased() ?? ""
    let itemId = metadata["item_id"]?.stringValue ?? ""
    let isProviderItem = phase.hasPrefix("item.") && !name.isEmpty
    let isToolProjection = event.type == "tool"
        || (event.type == "progress" && isProviderItem && name != "reasoning")
    let id = (event.type == "tool" || event.type == "thinking" || isProviderItem) && !itemId.isEmpty
        ? "\(event.traceId):item:\(itemId)"
        : event.id ?? "\(event.traceId):\(event.sequence)"

    func activity(
        _ kind: AtlasAgentActivity.Kind,
        _ title: String,
        detail: String? = nil
    ) -> AtlasAgentActivity {
        AtlasAgentActivity(
            id: id,
            sequence: event.sequence,
            kind: kind,
            title: title,
            detail: detail.map(safeActivityDetail),
            occurredAt: event.occurredAt
        )
    }

    if event.type == "permission" {
        return activity(.permission, "Verificando permissões")
    }
    if event.type == "error" || event.type == "stderr" {
        return activity(.warning, "A execução encontrou um alerta")
    }
    if event.type == "stdout" || event.type == "response" {
        return nil
    }
    if event.type == "thinking" || (event.type == "progress" && isProviderItem && name == "reasoning") {
        return activity(.reasoning, "Raciocinando sobre a tarefa")
    }
    if event.type == "token",
       name == "stdout_chunk" || metadata["parser"]?.stringValue?.lowercased() == "stdout_chunk" {
        return activity(.reasoning, "Raciocinando sobre a tarefa")
    }
    if checkpoint == "provider_thinking" {
        return activity(.reasoning, "Raciocinando sobre a tarefa")
    }
    if event.type == "token" {
        return nil
    }

    if let toolActivity = atlasAgentActivityFromToolProjection(
        event: event, metadata: metadata, name: name, phase: phase, id: id, isToolProjection: isToolProjection
    ) {
        return toolActivity
    }

    if name == "process_started" {
        return activity(.executing, "Iniciando o agente")
    }
    if name == "process_finished" {
        let succeeded = metadata["successful"]?.boolValue
            ?? metadata["exit_code"]?.doubleValue.map { $0 == 0 }
            ?? false
        return activity(succeeded ? .completed : .warning,
                        succeeded ? "Comando concluído" : "Comando terminou com falha")
    }

    let classifier = "\(name) \(checkpoint)"
    if classifier.contains("edit") || classifier.contains("write") || classifier.contains("patch") || classifier.contains("apply") {
        return activity(.editing, "Editando arquivos", detail: pathDetail(metadata))
    }
    if classifier.contains("read") || classifier.contains("inspect") || classifier.contains("open") {
        return activity(.reading, "Lendo arquivos", detail: pathDetail(metadata))
    }
    if classifier.contains("search") || classifier.contains("grep") || classifier.contains("find") {
        return activity(.reading, "Buscando no projeto", detail: pathDetail(metadata))
    }
    if classifier.contains("verify") || classifier.contains("test") || classifier.contains("check") || classifier.contains("gate") {
        return activity(.verifying, "Verificando o resultado")
    }

    switch checkpoint {
    case "intent": return activity(.understanding, "Entendendo o pedido")
    case "context": return activity(.context, "Reunindo contexto")
    case "plan": return activity(.planning, "Planejando a execução")
    case "provider":
        return outcome == "started"
            ? activity(.executing, "Iniciando o agente")
            : activity(.completed, "Execução do agente concluída")
    case "verify": return activity(.verifying, "Verificando o resultado")
    case "evidence": return activity(.evidence, "Registrando evidências")
    default: break
    }

    if event.type == "progress" || event.type == "lifecycle" {
        return activity(.progress, "Executando a tarefa")
    }
    return nil
}
