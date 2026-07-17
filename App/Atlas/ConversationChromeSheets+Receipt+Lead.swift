import SwiftUI
import AtlasCore

// Icon — peel de ConversationHandoffReceipt.
// Copy → ConversationChromeSheets+Receipt+CopyStack.swift

extension ConversationHandoffReceipt {
    var receiptIcon: some View {
        Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .modifier(ReceiptSpinEffect(active: isPending && !reduceMotion))
            .accessibilityHidden(true)
    }
}

// iOS 17 compat: `.symbolEffect(.rotate,…)` exige iOS 18. Rotação contínua
// própria (deploymentTarget = iOS 17), respeitando Reduce Motion via `active`.
private struct ReceiptSpinEffect: ViewModifier {
    let active: Bool
    @State private var spinning = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(active && spinning ? 360 : 0))
            .animation(active ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                       value: spinning)
            .onAppear { if active { spinning = true } }
            .onChange(of: active) { _, now in spinning = now }
    }
}
