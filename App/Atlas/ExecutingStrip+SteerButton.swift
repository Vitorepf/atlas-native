import SwiftUI

// Cycle 041 fuse → ExecutingStrip+SteerButton.swift

extension ExecutingStrip {
    @ViewBuilder
    var steerActionButton: some View {
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
    }
}
