import SwiftUI
import AtlasCore

// Accessibility shell — peel de SteerInteractionSheet.

extension SteerInteractionSheet {
    func steerA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.steerSheet)
            .accessibilityLabel("redirecionar execução \(traceId.rawValue)")
            .accessibilityHint(spokenSheetHint())
    }
}
