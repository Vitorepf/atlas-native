import SwiftUI
import AtlasCore

// Linhas da timeline — peel de LiveTimeline (régua anti-inchaço).
// Cada passo espelha um `AtlasAgentActivity` real; a casca não inventa títulos.
// Ícones → LiveTimeline+ActivityIcon.swift · Annotate → +Annotate.swift

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
            style: isNarrativeIntentKind(activity.kind) ? .intent : .single,
            title: activity.title,
            detail: activity.detail,
            occurredAt: AtlasTime.date(activity.occurredAt)
        )
    }
    annotateNarrativeDurations(&rows)
    return rows
}
