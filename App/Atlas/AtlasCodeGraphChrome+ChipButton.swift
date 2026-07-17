import SwiftUI
import AtlasCore

// Chip button label — peel de AtlasCodeGraphChrome+Chips.
// Label → AtlasCodeGraphChrome+ChipLabel.swift
// A11y → AtlasCodeGraphChrome+ChipA11y.swift

extension AtlasCodeView {
    func graphStateChipButton(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        filterSilence: Bool
    ) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                graphStateFilter = option
            }
        } label: {
            graphStateChipLabel(option, count: count, active: active)
        }
        .buttonStyle(.plain)
        .graphStateChipA11y(option, count: count, active: active, filterSilence: filterSilence)
    }
}
