import AtlasCore
import SwiftUI

// Cycle 040 fuse → ChangeReviewCouncilSection+RevisionsLine.swift

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func councilBlockHeader(diverged: Bool) -> some View {
        HStack(spacing: 8) {
            Text("Conselho")
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityAddTraits(.isHeader)
            if diverged {
                Text("divergência")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityLabel("divergência entre pareceres")
            }
        }
    }
}

extension ChangeReviewGovernanceSection {
    func governanceChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.45), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityIdentifier(A11yID.reviewGovernance)
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceCouncilBlock(_ council: [AtlasTraceGovernance.CouncilMember]) -> some View {
        if !council.isEmpty {
            councilBlock(council)
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceRevisionsLine(_ revisions: [AtlasTraceGovernance.PlanRevision]) -> some View {
        if let last = revisions.last {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .atlasSans(11)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(revisions.count == 1
                     ? "plano v1 arquivado — \(last.humanReason)"
                     : "\(revisions.count) versões de plano arquivadas — \(last.humanReason)")
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }
}

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
