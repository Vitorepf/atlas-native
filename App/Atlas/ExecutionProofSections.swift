import AtlasCore
import SwiftUI

// WAVE-113 decision/quality/activities sections

// MARK: - Sections (decision / quality / activities)

extension ExecutionProof {
    @ViewBuilder
    var decisionBlock: some View {
        if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
            decisionSummaryRow(d)
            decisionReason(d)
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    func decisionSummaryRow(_ d: AtlasDecisionSummary) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.branch")
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                .accessibilityHidden(true)
            Text(decideLine(d))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(decisionSpoken(d))
    }
}

extension ExecutionProof {
    @ViewBuilder
    var qualityBlock: some View {
        if let q = bubble.qualitySummary {
            HStack(spacing: 6) {
                Image(systemName: "seal")
                    .atlasSans(11).foregroundStyle(qualityColor(q)).frame(width: 15)
                    .accessibilityHidden(true)
                Text(qualityLine(q))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .accessibilityLabel(qualitySpoken(q))
        }
    }

    func qualityColor(_ q: AtlasQualitySummary) -> Color {
        q.status.lowercased().contains("pass") || q.score >= 0.7
            ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional
    }

}

extension ExecutionProof {
    @ViewBuilder
    func decisionReason(_ d: AtlasDecisionSummary) -> some View {
        if let r = d.reason, !r.isEmpty {
            Text("\"\(r)\"")
                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .padding(.leading, 23)
                .accessibilityLabel(ExecutionProofJudgment.spokenReason(r))
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var expandedProofContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            replayScrubber
            activityRows
            decisionBlock
            qualityBlock
            artifactsBlock
        }
        .padding(.top, 8)
        .padding(.leading, 4)
        .transition(reduceMotion ? .identity : .opacity)
        .onChange(of: bubble.activities.count) {
            replayIndex = min(replayIndex, max(0, timestampedActivities.count - 1))
        }
    }
}

extension ExecutionProof {
    var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }
}

extension ExecutionProof {
    var proofFace: ExecutionProofFace {
        ExecutionProofJudgment.face(bubble: bubble, artifactItems: rankedArtifactItems)
    }

    /// WAVE-042: kind-attention artifacts (shared with ArtifactJudgment).
    var rankedArtifactItems: [AtlasTraceArtifacts.Item] {
        ExecutionProofJudgment.rankedArtifacts(artifactItems)
    }

    var summaryLine: String {
        ExecutionProofJudgment.summaryLine(
            bubble: bubble,
            artifactItems: rankedArtifactItems,
            humanDuration: humanDuration
        )
    }
}

extension ExecutionProof {
    /// WAVE-082: activity/quality spoken owned by ExecutionProofJudgment.
    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        ExecutionProofJudgment.activitySpoken(act)
    }

    func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        ExecutionProofJudgment.qualityLineFlags(q, base: base)
    }

    func qualityLine(_ q: AtlasQualitySummary) -> String {
        ExecutionProofJudgment.qualityLine(q)
    }

    func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        ExecutionProofJudgment.qualitySpoken(q)
    }
}

extension ExecutionProof {
    @ViewBuilder
    var replayScrubber: some View {
        let stamped = timestampedActivities
        if stamped.count >= 2 {
            let index = min(replayIndex, stamped.count - 1)
            let selected = stamped[index]
            replayScrubberChrome(index: index, total: stamped.count, selected: selected)
        } else if !bubble.activities.isEmpty {
            Text(ExecutionProofJudgment.replayUnavailableLabel)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(ExecutionProofJudgment.replayUnavailableSpoken)
        }
    }
}

