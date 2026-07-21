import SwiftUI
import AtlasCore

// Pulse lifecycle — peel de LiveTimeline+NarrativeA11y.

extension NarrativeRowView {
    func narrativePulseLifecycle() -> some View {
        narrativeA11y
            .onAppear {
                if isCurrent && !reduceMotion {
                    withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
                }
            }
            .onChange(of: isCurrent) { _, now in if !now { pulse = false } }
    }
}
