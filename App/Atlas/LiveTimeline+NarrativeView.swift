import SwiftUI
import AtlasCore

// Linha narrativa da timeline — peel de LiveTimeline+Rows.
// Body → LiveTimeline+NarrativeBody.swift
// A11y → LiveTimeline+NarrativeA11y.swift

struct NarrativeRowView: View {
    let row: NarrativeRow
    let index: Int
    let total: Int
    let isCurrent: Bool
    let isLast: Bool
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        narrativePulseLifecycle()
    }
}
