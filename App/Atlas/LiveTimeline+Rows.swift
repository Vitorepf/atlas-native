import SwiftUI
import AtlasCore

// Linhas da timeline — peel de LiveTimeline (régua anti-inchaço).
// Cada passo espelha um `AtlasAgentActivity` real; a casca não inventa títulos.
// Ícones → LiveTimeline+ActivityIcon.swift · Annotate → +Annotate.swift
// Row → LiveTimeline+NarrativeRow.swift
// Map → LiveTimeline+Rows+Map.swift

/// Projeta atividades reais 1:1 — sem agregar nem renomear ferramentas.
func narrativeRows(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    var rows = narrativeRowMap(from: activities)
    annotateNarrativeDurations(&rows)
    return rows
}
