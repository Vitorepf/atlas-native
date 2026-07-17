import SwiftUI
import AtlasCore

// Conteúdo expandido da prova — peel de ExecutionProof.

extension ExecutionProof {
    @ViewBuilder
    var expandedProofContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            replayScrubber
            if !bubble.activities.isEmpty {
                ForEach(bubble.activities) { act in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: activityIcon(act.kind))
                            .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                            .frame(width: 15)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(act.title)
                                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                            if let d = act.detail, !d.isEmpty {
                                Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                                    .lineLimit(2).truncationMode(.middle)
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(activitySpoken(act))
                }
            }
            if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
                Divider().overlay(AtlasTheme.separatorSoft)
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                    Text(decideLine(d))
                        .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                }
                if let r = d.reason, !r.isEmpty {
                    Text(""\(r)"")
                        .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.leading, 23)
                }
            }
            if let q = bubble.qualitySummary {
                HStack(spacing: 6) {
                    Image(systemName: "seal")
                        .font(.system(size: 11)).foregroundStyle(qualityColor(q)).frame(width: 15)
                    Text(qualityLine(q))
                        .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                }
                .accessibilityLabel(qualitySpoken(q))
            }
            if !artifactItems.isEmpty, let traceId = bubble.traceId {
                Button {
                    if !reduceMotion {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                    onOpenArtifacts(traceId)
                } label: {
                    HStack(spacing: 6) {
                        Text("⎘")
                            .font(AtlasFont.mono(12))
                            .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                            .frame(width: 15)
                        Text("ARTEFATOS (\(artifactItems.count))")
                            .font(AtlasFont.mono(12))
                            .foregroundStyle(AtlasTheme.textSecondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.artifactsRow)
                .accessibilityLabel("artefatos desta execução, \(artifactItems.count)")
            }
        }
        .padding(.top, 8)
        .padding(.leading, 4)
        .transition(reduceMotion ? .identity : .opacity)
        .onChange(of: bubble.activities.count) {
            replayIndex = min(replayIndex, max(0, timestampedActivities.count - 1))
        }
    }
}
