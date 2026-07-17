import AtlasCore

/// Ícone por kind de atividade (vocabulário estável do contrato C5).
/// Peel de LiveTimeline+Rows.

func activityIcon(_ kind: AtlasAgentActivity.Kind) -> String {
    switch kind {
    case .understanding: return "text.magnifyingglass"
    case .context: return "square.stack.3d.up"
    case .planning: return "list.bullet.rectangle"
    case .permission: return "lock.shield"
    case .reasoning: return "brain"
    case .executing: return "chevron.left.forwardslash.chevron.right"
    case .reading: return "doc.text"
    case .editing: return "pencil.line"
    case .verifying: return "checkmark.seal"
    case .evidence: return "tray.full"
    case .completed: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .progress: return "ellipsis.circle"
    }
}
