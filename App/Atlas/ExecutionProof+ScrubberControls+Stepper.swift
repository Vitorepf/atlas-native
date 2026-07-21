import SwiftUI
import AtlasCore

// RM stepper — peel de ExecutionProof+ScrubberControls.

extension ExecutionProof {
    func replayStepperControl(stampedCount: Int) -> some View {
        Stepper("passo \(min(replayIndex, stampedCount - 1) + 1)", value: Binding(
            get: { replayIndex },
            set: { replayIndex = min(max(0, $0), stampedCount - 1) }
        ), in: 0...(stampedCount - 1))
        .labelsHidden()
        .accessibilityLabel("replay da execução, passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
    }
}
