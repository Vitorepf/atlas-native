import SwiftUI

// Botões da faixa de execução — peel de ExecutingStrip (régua ≤100).

extension ExecutingStrip {
    @ViewBuilder
    var stripActionButtons: some View {
        if let onSteer {
            Button(action: onSteer) {
                Text("Redirecionar")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("redirecionar execução")
            .accessibilityHint("abre opções para redirecionar a execução ao vivo")
        }
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
