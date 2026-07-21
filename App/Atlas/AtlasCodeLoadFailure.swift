import SwiftUI

// Cycle 043 fuse → AtlasCodeLoadFailure.swift

/// Falha de carregamento Código — canônico (radar + grafo).
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        failureA11y
    }
}

extension AtlasCodeLoadFailureEmpty {
    var failureIcon: some View {
        Image(systemName: "exclamationmark.triangle")
            .atlasSans(24)
            .foregroundStyle(AtlasCodePalette.alert)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var failureA11y: some View {
        failureStack
            // Contain: headline + retry stay separately focusable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var failureHeadline: some View {
        Text(headline)
            .font(AtlasFont.serif(20, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityAddTraits(.isHeader)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var failureMessage: some View {
        Text(message)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var failureStack: some View {
        VStack(spacing: 16) {
            failureIcon
            failureHeadline
            failureMessage
            retryButton
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 420, maxHeight: .infinity)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var retryButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRetry()
        } label: {
            Text("Tentar de novo")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .frame(minHeight: 48) // match primary CTA breath
                .background(
                    Capsule().fill(AtlasTheme.goldVeil)
                        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("tentar de novo")
        .accessibilityHint("recarrega o grafo ou radar deste repositório")
        .accessibilityIdentifier(A11yID.codeLoadRetry)
    }
}
