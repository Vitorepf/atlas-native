import SwiftUI

// Cycle 040 fuse → AtlasCodeLoadFailure+Message.swift

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
