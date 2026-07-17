import SwiftUI
import AtlasCore

// Status text do strip — peel de ExecutingStrip.
// Lines → +StatusLines · Meta (timer/diff) → +StatusMeta

extension ExecutingStrip {
    @ViewBuilder
    var stripStatus: some View {
        HStack(spacing: 8) {
            stripStatusLeading
            stripStatusTitle
            stripStatusMeta
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
    }
}
