import SwiftUI
import AtlasCore

// Axis header row — peel de ChangeReviewFindingsSection+Axis.

extension ChangeReviewFindingsSection {
    func axisHeaderRow(axis: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(axis).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.accent)
            Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
            Text("\(count)")
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(axisHeaderLabel(axis: axis, count: count))
        .accessibilityIdentifier(A11yID.reviewFindingAxis(axis))
    }
}
