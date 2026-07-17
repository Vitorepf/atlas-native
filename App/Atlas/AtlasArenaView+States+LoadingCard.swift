import SwiftUI
import AtlasCore

// Loading card — peel de AtlasArenaView+States.

extension AtlasArenaView {
    var loadingCard: some View {
        TraceEvidenceLoading(text: "carregando índice medido…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
    }
}
