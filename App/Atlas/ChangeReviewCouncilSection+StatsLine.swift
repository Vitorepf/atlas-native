import SwiftUI
import AtlasCore

// Stats line — peel de ChangeReviewCouncilSection+Lines.

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceStatsLine(_ stats: AtlasTraceGovernance.DiffStats) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "plusminus")
                .atlasSans(11)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(stats.headline)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityLabel("\(stats.filesTouched) arquivos, mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
        }
    }
}
