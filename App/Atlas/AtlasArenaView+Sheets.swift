import SwiftUI
import AtlasCore

// Sheets — peel de AtlasArenaView.

extension AtlasArenaView {
    func arenaSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $selectedSuite) { suite in
                ArenaSuiteSheet(suite: suite)
            }
            .sheet(item: $selectedEngine) { engine in
                ArenaEngineSheet(engine: engine, capabilities: model.capabilities)
            }
            .sheet(isPresented: $showingRunSheet) {
                ArenaRunSheet(model: model)
            }
    }
}
