import SwiftUI
import AtlasCore

// Sheets live da Arena premium (Run + Suite). Engine sheet classic removido.

extension AtlasArenaView {
    func arenaSheets<Content: View>(on content: Content) -> some View {
        content
            // Suite sheet vive no ArenaPremiumShell (estado local) — evita
            // sheet(item:) órfão no contentor que não reapresentava no iOS 26.
            .sheet(isPresented: $showingRunSheet) {
                ArenaRunSheet(model: model)
            }
    }
}
