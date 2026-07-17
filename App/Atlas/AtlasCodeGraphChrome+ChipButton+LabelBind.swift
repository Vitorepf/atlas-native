import SwiftUI
import AtlasCore

// Chip label bind — peel de AtlasCodeGraphChrome+ChipButton.
// Action → AtlasCodeGraphChrome+ChipButton+Action.swift

extension AtlasCodeView {
    func graphStateChipLabelBind(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        filterSilence: Bool
    ) -> some View {
        Button {
            graphStateChipAction(option)
        } label: {
            graphStateChipLabel(option, count: count, active: active)
        }
        .buttonStyle(.plain)
        .graphStateChipA11y(option, count: count, active: active, filterSilence: filterSilence)
    }
}
