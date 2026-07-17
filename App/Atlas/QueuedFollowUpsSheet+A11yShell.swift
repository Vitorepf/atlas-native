import SwiftUI

// A11y shell — peel de QueuedFollowUpsSheet.

extension QueuedFollowUpsSheet {
    func queueSheetA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.queueSheet)
            .accessibilityLabel(spokenQueueSheetLabel())
            .accessibilityHint("promover ou remover só mensagens reais da fila do model")
    }
}
