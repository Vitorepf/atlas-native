import Foundation

extension AtlasAgentActivity {
    static func classifierActivity(
        from event: AtlasAiStreamEvent,
        metadata: JSONObject,
        name: String,
        checkpoint: String,
        id: String
    ) -> AtlasAgentActivity? {
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
        return nil
    }
}
