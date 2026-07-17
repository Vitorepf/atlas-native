import SwiftUI
import AtlasCore

// Control sheet only — peel de AutonomosSheetsModifier+Control.

extension AutonomosSheetsModifier {
    @ViewBuilder
    func controlSheetOnly<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $control) { action in
                AutonomosControlSheet(action: action) { actor, reason in
                    Task { await model.control(action, operatorActor: actor, reason: reason) }
                }
            }
    }
}
