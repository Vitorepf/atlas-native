import Foundation

/// Projeção de eventos de ferramenta/provider item — peel de FromEvent.
func atlasAgentActivityFromToolProjection(
    event: AtlasAiStreamEvent,
    metadata: JSONObject,
    name: String,
    phase: String,
    id: String,
    isToolProjection: Bool
) -> AtlasAgentActivity? {
    guard isToolProjection else { return nil }

    let status = metadata["status"]?.stringValue?.lowercased() ?? ""
    let exitCode = metadata["exit_code"]?.doubleValue.map(Int.init)
    let failed = exitCode.map { $0 != 0 } == true || ["failed", "error", "cancelled"].contains(status)
    let finished = phase.contains("completed") || ["completed", "succeeded", "failed"].contains(status)

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

    if name == "read" || name.contains("read_file") || name.contains("open_file") {
        if failed { return activity(.warning, "Leitura terminou com falha", detail: safeFileSummary(event.content)) }
        return finished
            ? activity(.completed, "Leitura concluída", detail: safeFileSummary(event.content))
            : activity(.reading, "Lendo arquivos", detail: safeFileSummary(event.content))
    }
    if name.contains("edit") || name.contains("write") || name.contains("patch") || name.contains("apply") {
        if failed { return activity(.warning, "Edição terminou com falha", detail: safeFileSummary(event.content)) }
        return finished
            ? activity(.completed, "Edição concluída", detail: safeFileSummary(event.content))
            : activity(.editing, "Editando arquivos", detail: safeFileSummary(event.content))
    }
    if name.contains("search") || name.contains("find") || name.contains("grep") {
        if failed { return activity(.warning, "Busca terminou com falha", detail: safeActivityDetail(event.content)) }
        return finished
            ? activity(.completed, "Busca concluída", detail: safeActivityDetail(event.content))
            : activity(.reading, "Buscando no projeto", detail: safeActivityDetail(event.content))
    }
    if name == "shell" || name.contains("bash") || name.contains("exec") || name == "run" {
        if failed { return activity(.warning, "Comando terminou com falha", detail: safeCommandText(event.content)) }
        if finished {
            return activity(.completed, "Comando concluído", detail: safeCommandText(event.content))
        }
        return activity(.executing, "Executando comando", detail: safeCommandText(event.content))
    }
    if failed { return activity(.warning, "Ferramenta terminou com falha") }
    return finished
        ? activity(.completed, "Ferramenta concluída")
        : activity(.executing, "Usando ferramenta")
}
