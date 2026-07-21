import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    /// WAVE-078: exclusive editorial-empty face.
    var emptyFace: WorkspaceEmptyFace {
        WorkspaceEmptyJudgment.face(
            area: area, freeOnly: freeOnly, screenTitle: screenTitle
        )
    }

    var body: some View {
        editorialGlyph
    }

    var editorialGlyph: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            footnote: footnote,
            accessibilityIdentifier: A11yID.workspaceEmpty,
            spokenLabel: spokenLabel,
            accessibilityValue: emptyFace.productWord
        )
    }

    var headline: String {
        WorkspaceEmptyJudgment.headline(face: emptyFace)
    }

    var footnote: String {
        WorkspaceEmptyJudgment.footnote(face: emptyFace)
    }

    var spokenLabel: String {
        WorkspaceEmptyJudgment.spokenLabel(
            area: area, freeOnly: freeOnly, screenTitle: screenTitle
        )
    }
}

private struct OptionalAccessibilityValue: ViewModifier {
    let value: String?
    func body(content: Content) -> some View {
        if let value {
            content.accessibilityValue(value)
        } else {
            content
        }
    }
}

struct AtlasEditorialGlyphEmpty: View {
    let headline: String
    var footnote: String? = nil
    let accessibilityIdentifier: String
    var spokenLabel: String? = nil
    var accessibilityValue: String? = nil

    var body: some View {
        editorialStack
            .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel ?? headline)
            .modifier(OptionalAccessibilityValue(value: accessibilityValue))
            .accessibilityIdentifier(accessibilityIdentifier)
    }

    var editorialStack: some View {
        VStack(spacing: 14) {
            editorialGlyph
            editorialCopyStack
        }
    }

    var editorialGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            .accessibilityHidden(true)
    }

    var editorialCopyStack: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            if let footnote {
                Text(footnote)
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .accessibilityHidden(true)
            }
        }
    }
}

struct WorkspaceLoadingEmpty: View {
    var reduceMotion: Bool
    var text: String = "abrindo conversas…"
    var spoken: String? = nil
    var topPadding: CGFloat = 72

    var body: some View {
        VStack(spacing: 18) {
            BreathingGlyph(reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity).padding(.top, topPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken ?? text)
    }
}

struct AtlasNetworkFailureEmpty: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
    var topPadding: CGFloat = 56
    var retryHint: String = "reconecta ao servidor Atlas"
    var retryAccessibilityIdentifier: String?
    let accessibilityIdentifier: String
    let onRetry: () -> Void

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: .network(kind: kind, hasToken: hasToken, host: host),
            layout: .centered,
            topPadding: topPadding,
            accessibilityIdentifier: accessibilityIdentifier,
            retryAccessibilityIdentifier: retryAccessibilityIdentifier,
            retryHint: retryHint,
            onRetry: onRetry
        )
    }
}
