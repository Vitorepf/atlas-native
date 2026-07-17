import AtlasCore

/// Ícone por kind de atividade (vocabulário estável do contrato C5).
/// Peel de LiveTimeline+Rows.
/// Intent → LiveTimeline+ActivityIcon+Intent.swift
/// Tool → LiveTimeline+ActivityIcon+Tool.swift
/// Terminal → LiveTimeline+ActivityIcon+Terminal.swift

func activityIcon(_ kind: AtlasAgentActivity.Kind) -> String {
    activityIconIntent(kind)
        ?? activityIconTool(kind)
        ?? activityIconTerminal(kind)
        ?? "ellipsis.circle"
}
