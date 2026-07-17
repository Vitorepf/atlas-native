import SwiftUI
import AtlasCore

// Controles slider/stepper — peel de ExecutionProof+Scrubber.

extension ExecutionProof {
    @ViewBuilder
    func replayControls(stampedCount: Int) -> some View {
        if reduceMotion {
            Stepper("passo \(min(replayIndex, stampedCount - 1) + 1)", value: Binding(
                get: { replayIndex },
                set: { replayIndex = min(max(0, $0), stampedCount - 1) }
            ), in: 0...(stampedCount - 1))
            .labelsHidden()
            .accessibilityLabel("replay da execução, passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
        } else {
            Slider(value: Binding(
                get: { Double(replayIndex) },
                set: { replayIndex = min(max(0, Int($0.rounded())), stampedCount - 1) }
            ), in: 0...Double(stampedCount - 1), step: 1)
            .tint(AtlasTheme.accent)
            .accessibilityLabel("scrubber de replay da execução")
            .accessibilityValue("passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
        }
    }
}
