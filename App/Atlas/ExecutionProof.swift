import AtlasCore
import SwiftUI

// WAVE-113 host + body

// MARK: - Types / Inputs

struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var open = false
    @State var replayIndex = 0

    // MARK: Body

    var body: some View {
        proofChrome { proofStack }
    }
}

extension ExecutionProof {
    func activityRowCopy(_ act: AtlasAgentActivity) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(act.title)
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            if let d = act.detail, !d.isEmpty {
                Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2).truncationMode(.middle)
            }
        }
    }
}

extension ExecutionProof {
    func activityRowCell(index: Int, act: AtlasAgentActivity) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            activityRowCopy(act)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "passo \(index + 1) de \(bubble.activities.count), \(activitySpoken(act))"
        )
    }
}

extension ExecutionProof {
    @ViewBuilder
    var activityRows: some View {
        if !bubble.activities.isEmpty {
            ForEach(Array(bubble.activities.enumerated()), id: \.element.id) { index, act in
                activityRowCell(index: index, act: act)
            }
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var artifactsBlock: some View {
        if !artifactItems.isEmpty, let traceId = bubble.traceId {
            artifactsButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onOpenArtifacts(traceId)
                } label: {
                    artifactsButtonLabel(count: artifactItems.count)
                },
                count: artifactItems.count
            )
        }
    }
}

extension ExecutionProof {
    func artifactsButtonA11y<Content: View>(_ content: Content, count: Int) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11yID.artifactsRow)
            .accessibilityLabel(ExecutionProofJudgment.spokenArtifactsCTA(count: count))
            .accessibilityHint(ExecutionProofJudgment.artifactsHint)
    }
}

extension ExecutionProof {
    var artifactsChevron: some View {
        Image(systemName: "chevron.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension ExecutionProof {
    func artifactsButtonLabel(count: Int) -> some View {
        HStack(spacing: 6) {
            artifactsButtonLead(count: count)
            artifactsChevron
        }
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    func artifactsButtonLead(count: Int) -> some View {
        HStack(spacing: 6) {
            Text("⎘")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            Text("ARTEFATOS (\(count))")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
            Spacer()
        }
    }
}

