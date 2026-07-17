import SwiftUI
import AtlasCore

// Control / start-run sheets — peel de AutonomosSheetsModifier.
// Start → AutonomosSheetsModifier+ControlStart.swift

extension AutonomosSheetsModifier {
    @ViewBuilder
    func controlSheets<Content: View>(on content: Content) -> some View {
        startRunSheet(on:
            content
                .sheet(item: $control) { action in
                    AutonomosControlSheet(action: action) { actor, reason in
                        Task { await model.control(action, operatorActor: actor, reason: reason) }
                    }
                }
        )
    }
}
