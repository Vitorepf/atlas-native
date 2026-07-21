import SwiftUI
import AtlasCore

// Autônomos lifecycle chrome — peel de AutonomosView.
// Sheets mortas (frota/transfer/control) removidas na Onda 1 — só New/Ask no MapShell.

extension AutonomosView {
    func autonomosLifecycleChrome<Content: View>(_ content: Content) -> some View {
        autonomosLifecycleScreenA11y(content)
    }
}
