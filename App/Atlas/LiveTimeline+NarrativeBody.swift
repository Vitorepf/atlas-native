import SwiftUI
import AtlasCore

// Corpo da linha narrativa — peel de NarrativeRowView.
// Meta → +NarrativeMeta · Spine → +NarrativeSpine.swift
// Text → LiveTimeline+NarrativeText.swift

extension NarrativeRowView {
    var narrativeBody: some View {
        HStack(alignment: .top, spacing: 10) {
            narrativeSpine
            narrativeTextStack
            Spacer(minLength: 0)
        }
    }
}
