import SwiftUI

// Botões da faixa de execução — peel de ExecutingStrip (régua ≤100).
// Steer → ExecutingStrip+SteerButton.swift

extension ExecutingStrip {
    @ViewBuilder
    var stripActionButtons: some View {
        steerActionButton
        Button(action: onStop) {
            Text("Parar")
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("parar execução")
        .accessibilityHint("interrompe a execução ao vivo")
    }
}
