import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Handoff toast + queue close — peel de ConversationSheets+Modifier.

extension ConversationComposerSheetsModifier {
    func handoffAndQueueObservers<Content: View>(on content: Content) -> some View {
        content
            .onChange(of: model.queuedMessages.isEmpty) { _, empty in
                if empty { showQueueSheet = false }
            }
            .onChange(of: model.latestSurfaceHandoff?.id) {
                guard let h = model.latestSurfaceHandoff, h.status == "ready" else { return }
                let destino = atlasSurfaceLabel(h.toSurface)
                model.toast = "Pronto no \(destino) — mesma conversa, mesma sessão."
            }
    }
}
