import SwiftUI
import AtlasCore

// Linha narrativa da timeline — peel de LiveTimeline+Rows.
// Body → LiveTimeline+NarrativeBody.swift

struct NarrativeRowView: View {
    let row: NarrativeRow
    let index: Int
    let total: Int
    let isCurrent: Bool
    let isLast: Bool
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        narrativeBody
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(LiveTimelineA11y.spokenRow(row: row,
                                                       index: index,
                                                       total: total,
                                                       isCurrent: isCurrent))
        .accessibilityValue(LiveTimelineA11y.rowValue(index: index, total: total, isCurrent: isCurrent))
        .accessibilityAddTraits(currentTraits)
        .onAppear {
            if isCurrent && !reduceMotion {
                withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
            }
        }
        .onChange(of: isCurrent) { _, now in if !now { pulse = false } }
    }
}
