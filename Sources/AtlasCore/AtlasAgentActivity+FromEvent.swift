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

    // CodexJsonlEventParser produz `tool`, porém AiStreamRecorder atualmente
    // normaliza tipos fora de sua allowlist para `progress`. `name` + `phase`
    // + `item_id` sobrevivem no ledger, então ambos os shapes projetam a mesma
    // ferramenta segura e persistente. Nunca mostramos output_excerpt nem
    // reasoning do provider.
    if isToolProjection {
        let status = metadata["status"]?.stringValue?.lowercased() ?? ""
        let exitCode = metadata["exit_code"]?.doubleValue.map(Int.init)
        let failed = exitCode.map { $0 != 0 } == true || ["failed", "error", "cancelled"].contains(status)
        let finished = phase.contains("completed") || ["completed", "succeeded", "failed"].contains(status)

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

    if name == "process_started" {
        // Este é o processo do provider (Kimi/Codex/Claude), não uma tool do
        // agente. Exibir argv aqui criava uma ferramenta falsa e vazava paths.
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

fileprivate func containsSensitiveCommandMaterial(_ lower: String) -> Bool {
    let sensitiveMarkers = [
        "authorization:", "bearer ", "token=", "token:", "api_key=", "api-key=",
        "apikey=", "secret=", "secret:", "password=", "password:", "private_key=",
        "--token", "--api-key", "--apikey", "--secret", "--password", "--private-key",
    ]
    return sensitiveMarkers.contains(where: lower.contains)
}

fileprivate func safeCommandText(_ value: String) -> String {
    let singleLine = value.replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "\r", with: " ")
    guard !containsSensitiveCommandMaterial(singleLine.lowercased()) else { return "<redacted>" }
    return String(singleLine.prefix(240))
}

fileprivate func safeFileSummary(_ value: String) -> String {
    value.split(separator: ",", maxSplits: 4).map { raw in
        let path = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return (path as NSString).lastPathComponent
    }.filter { !$0.isEmpty }.joined(separator: ", ")
}

fileprivate func pathDetail(_ metadata: JSONObject) -> String? {
    for key in ["path", "file", "file_path", "relative_path"] {
        if let value = metadata[key]?.stringValue, !value.isEmpty {
            return (value as NSString).lastPathComponent
        }
    }
    return nil
}

fileprivate func safeActivityDetail(_ value: String) -> String {
    let singleLine = value.replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "\r", with: " ")
    return String(singleLine.prefix(240))
}
