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
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(headline). \(message)")
            .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var failureHeadline: some View {
        Text(headline)
            .font(AtlasFont.serif(20, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var failureMessage: some View {
        Text(message)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var failureStack: some View {
        VStack(spacing: 14) {
            failureIcon
            failureHeadline
            failureMessage
            retryButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension AtlasCodeLoadFailureEmpty {
    var retryButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRetry()
        } label: {
            Text("Tentar de novo")
        }
        .buttonStyle(.borderedProminent)
        .tint(AtlasTheme.accent)
        .accessibilityLabel("tentar de novo")
        .accessibilityHint("recarrega o grafo ou radar deste repositório")
        .accessibilityIdentifier(A11yID.codeLoadRetry)
    }
}
