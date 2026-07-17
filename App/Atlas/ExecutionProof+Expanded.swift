import SwiftUI
import AtlasCore

// Conteúdo expandido da prova — peel de ExecutionProof.
// Blocos decisão/quality/artefatos → +Blocks.

extension ExecutionProof {
    @ViewBuilder
    var expandedProofContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            replayScrubber
            if !bubble.activities.isEmpty {
                ForEach(Array(bubble.activities.enumerated()), id: \.element.id) { index, act in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: activityIcon(act.kind))
                            .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                            .frame(width: 15)
                            .accessibilityHidden(true)
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
                    .accessibilityLabel(
                        "passo \(index + 1) de \(bubble.activities.count), \(activitySpoken(act))"
                    )
                }
            }
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
