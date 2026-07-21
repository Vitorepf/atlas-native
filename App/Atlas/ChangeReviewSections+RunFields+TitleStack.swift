import SwiftUI
import AtlasCore

// Title stack — peel de ChangeReviewSections+RunFields.

extension ChangeReviewRunHeader {
    @ViewBuilder
    var runHeaderTitleStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(run.decision ?? run.status ?? "revisão")
                .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let finished = run.finishedAt {
                Text(finished).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}
