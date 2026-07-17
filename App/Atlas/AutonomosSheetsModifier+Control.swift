import SwiftUI
import AtlasCore

// Control / start-run sheets — peel de AutonomosSheetsModifier.

extension AutonomosSheetsModifier {
    @ViewBuilder
    func controlSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $control) { action in
                AutonomosControlSheet(action: action) { actor, reason in
                    Task { await model.control(action, operatorActor: actor, reason: reason) }
                }
            }
            .sheet(item: $startRunMode) { mode in
                AutonomosStartRunSheet(mode: mode) { actor, reason in
                    Task { await model.startRun(mode: mode, operatorActor: actor, operatorReason: reason) }
                }
            }
    }
}
