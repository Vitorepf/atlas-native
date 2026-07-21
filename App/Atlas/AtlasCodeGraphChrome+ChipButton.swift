import SwiftUI
import AtlasCore

// Chip button label — peel de AtlasCodeGraphChrome+Chips.
// Action → AtlasCodeGraphChrome+ChipButton+Action.swift
// LabelBind → AtlasCodeGraphChrome+ChipButton+LabelBind.swift

extension AtlasCodeView {
    func graphStateChipButton(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        filterSilence: Bool
    ) -> some View {
        graphStateChipLabelBind(option, count: count, active: active, filterSilence: filterSilence)
    }
}
