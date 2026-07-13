import Foundation

/// Um passo observável da execução do agente. É uma projeção segura do wire:
/// mostra trabalho real sem despejar stdout, prompts, ids internos ou cadeia de
/// raciocínio. A View decide apresentação; o Core decide semântica e redaction.
public struct AtlasAgentActivity: Sendable, Equatable, Identifiable {
    public enum Kind: String, Sendable, Equatable {
        case understanding
        case context
        case planning
        case permission
        case reasoning
        case executing
        case reading
        case editing
        case verifying
        case evidence
        case completed
        case warning
        case progress
    }

    public let id: String
    public let sequence: Int
    public let kind: Kind
    public let title: String
    public let detail: String?
    public let occurredAt: String?

    public init(
        id: String,
        sequence: Int,
        kind: Kind,
        title: String,
        detail: String? = nil,
        occurredAt: String? = nil
    ) {
        self.id = id
        self.sequence = sequence
        self.kind = kind
        self.title = title
        self.detail = detail
        self.occurredAt = occurredAt
    }
}

/// Projeta eventos heterogêneos do servidor num vocabulário pequeno e estável.
/// `nil` significa que o evento é conteúdo de resposta ou ruído de transporte.
public func atlasAgentActivity(from event: AtlasAiStreamEvent) -> AtlasAgentActivity? {
    let metadata = event.metadata
    let name = metadata["name"]?.stringValue?.lowercased() ?? ""
    let checkpoint = metadata["checkpoint"]?.stringValue?.lowercased() ?? ""
    let outcome = metadata["outcome"]?.stringValue?.lowercased() ?? ""
    let id = event.id ?? "\(event.traceId):\(event.sequence)"

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

    if name == "process_started" {
        return activity(.executing, "Executando comando", detail: commandDetail(metadata["command"]))
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

private func commandDetail(_ value: JSONValue?) -> String? {
    guard case .array(let values)? = value else { return nil }
    let parts = values.compactMap(\.stringValue)
    guard !parts.isEmpty else { return nil }
    return parts.map { part in
        let lower = part.lowercased()
        if lower.contains("token=") || lower.contains("api_key=") || lower.contains("secret=") {
            return "<redacted>"
        }
        return part
    }.joined(separator: " ")
}

private func pathDetail(_ metadata: JSONObject) -> String? {
    for key in ["path", "file", "file_path", "relative_path"] {
        if let value = metadata[key]?.stringValue, !value.isEmpty {
            return (value as NSString).lastPathComponent
        }
    }
    return nil
}

private func safeActivityDetail(_ value: String) -> String {
    let singleLine = value.replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "\r", with: " ")
    return String(singleLine.prefix(240))
}
