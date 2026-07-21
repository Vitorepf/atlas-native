import SwiftUI
import AtlasCore

// Preview loading branch — peel de ArtifactSheet+PreviewStates+Busy.

extension ArtifactSheet {
    var previewPaneLoading: some View {
        TraceEvidenceLoading(text: "carregando preview…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, minHeight: 180)
    }
}
