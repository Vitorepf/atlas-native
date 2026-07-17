import AtlasCore

/// Intent/context activity icons — peel de LiveTimeline+ActivityIcon.

func activityIconIntent(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .understanding: return "text.magnifyingglass"
    case .context: return "square.stack.3d.up"
    case .planning: return "list.bullet.rectangle"
    case .permission: return "lock.shield"
    case .reasoning: return "brain"
    default: return nil
    }
}
