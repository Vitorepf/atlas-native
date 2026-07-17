import SwiftUI
import AtlasCore

// Duration meta — peel de NarrativeRowView+NarrativeBody.
// Traits → LiveTimeline+NarrativeTraits.swift
// Duration → LiveTimeline+NarrativeDuration.swift

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationMeta: some View {
        narrativeDurationChip
    }
}
