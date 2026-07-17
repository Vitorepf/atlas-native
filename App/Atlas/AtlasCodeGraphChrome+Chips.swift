import SwiftUI
import AtlasCore

// State filter chips — peel de AtlasCodeGraphChrome+Filters.
// Chip button → AtlasCodeGraphChrome+ChipButton.swift
// ChipLoop → AtlasCodeGraphChrome+Chips+ChipLoop.swift

extension AtlasCodeView {
    func graphStateChips(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                graphStateChipLoop(graph, filterSilence: filterSilence)
            }
        }
        .accessibilityIdentifier(A11yID.codeGraphFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: graphStateFilter)
    }
}
