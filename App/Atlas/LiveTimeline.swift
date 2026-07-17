import SwiftUI
import AtlasCore

// A narrativa viva da execução: cada linha espelha um `AtlasAgentActivity`
// real do contrato C5. Sem agregação inventada, sem placeholder quando vazio.
// Surfaces → LiveTimeline+Surfaces.swift
// Pipeline → LiveTimeline+RowPipeline.swift · Body → LiveTimeline+BodyGate.swift
struct LiveTimeline: View {
    let activities: [AtlasAgentActivity]
    let reduceMotion: Bool
    @State var filter: TimelineReadFilter = .all

    var body: some View {
        timelineBody
    }
}
