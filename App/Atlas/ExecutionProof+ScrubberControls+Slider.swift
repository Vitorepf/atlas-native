import SwiftUI
import AtlasCore

// Slider scrubber — peel de ExecutionProof+ScrubberControls.

extension ExecutionProof {
    func replaySliderControl(stampedCount: Int) -> some View {
        Slider(value: Binding(
            get: { Double(replayIndex) },
            set: { replayIndex = min(max(0, Int($0.rounded())), stampedCount - 1) }
        ), in: 0...Double(stampedCount - 1), step: 1)
        .tint(AtlasTheme.accent)
        .accessibilityLabel("scrubber de replay da execução")
        .accessibilityValue("passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
    }
}
