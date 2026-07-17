import SwiftUI
import AtlasCore

// Linhas da timeline — peel de LiveTimeline (régua anti-inchaço).
// Cada passo espelha um `AtlasAgentActivity` real; a casca não inventa títulos.

struct NarrativeRow: Identifiable, Equatable {
    enum Style { case intent, single }
    let id: String
    let style: Style
    let title: String
    let detail: String?
    let occurredAt: Date?
    var durationMs: Int? = nil
    var isP90: Bool = false
}

/// Projeta atividades reais 1:1 — sem agregar nem renomear ferramentas.
func narrativeRows(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    var rows = activities.map { activity in
        NarrativeRow(
            id: activity.id,
            style: isIntentKind(activity.kind) ? .intent : .single,
            title: activity.title,
            detail: activity.detail,
            occurredAt: AtlasTime.date(activity.occurredAt)
        )
    }
    annotateDurations(&rows)
    return rows
}

private func isIntentKind(_ kind: AtlasAgentActivity.Kind) -> Bool {
    [.understanding, .planning, .reasoning, .permission,
     .completed, .warning, .evidence, .verifying].contains(kind)
}

private func annotateDurations(_ rows: inout [NarrativeRow]) {
    guard rows.count > 1 else { return }
    for index in rows.indices.dropLast() {
        guard let start = rows[index].occurredAt,
              let end = rows[rows.index(after: index)].occurredAt else { continue }
        rows[index].durationMs = max(0, Int(end.timeIntervalSince(start) * 1000))
    }
    let durations = rows.compactMap(\.durationMs).sorted()
    guard !durations.isEmpty else { return }
    let p90Index = min(durations.count - 1, Int(ceil(Double(durations.count) * 0.9)) - 1)
    let threshold = durations[max(0, p90Index)]
    guard threshold > 0 else { return }
    for index in rows.indices {
        rows[index].isP90 = (rows[index].durationMs ?? 0) >= threshold
    }
}

/// Ícone por kind de atividade (vocabulário estável do contrato C5).
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
