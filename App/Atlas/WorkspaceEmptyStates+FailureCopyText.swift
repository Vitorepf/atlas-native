import AtlasCore
import SwiftUI

// Cycle 039 fuse → WorkspaceEmptyStates+FailureCopyText.swift

extension AtlasNetworkFailureEmpty {
    func failureChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 44).padding(.top, topPadding)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(accessibilityIdentifier)
            .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }
}

extension WorkspaceEditorialEmpty {
    var editorialGlyph: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            footnote: footnote,
            accessibilityIdentifier: A11yID.workspaceEmpty,
            spokenLabel: spokenLabel
        )
    }
}

extension AtlasNetworkFailureEmpty {
    var failureCopyBlock: some View {
        VStack(spacing: 0) {
            failureCopyText
            if hasToken {
                Spacer().frame(height: 28)
                retryButton
            }
        }
    }
}

extension AtlasNetworkFailureEmpty {
    var failureCopyText: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            Spacer().frame(height: 28)
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            Spacer().frame(height: 12)
            failureHostAndHint
        }
    }
}

extension AtlasNetworkFailureEmpty {
    var failureHostAndHint: some View {
        Group {
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
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

extension AtlasNetworkFailureEmpty {
    var retryLabel: some View {
        Text("Tentar de novo")
            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
            .padding(.horizontal, 22).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.goldVeil)
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
    }
}
