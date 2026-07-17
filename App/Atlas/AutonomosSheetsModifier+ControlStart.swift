import SwiftUI
import AtlasCore

// Start-run sheet — peel de AutonomosSheetsModifier+Control.

extension AutonomosSheetsModifier {
    @ViewBuilder
    func startRunSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $startRunMode) { mode in
                AutonomosStartRunSheet(mode: mode) { actor, reason in
                    Task { await model.startRun(mode: mode, operatorActor: actor, operatorReason: reason) }
                }
            }
    }
}
