import SwiftUI
import AtlasCore

// Loading shell — peel de AutonomosView+ContentShell.

extension AutonomosView {
    var loadingContent: some View {
        Group {
            preludeShell
            Spacer()
            TraceEvidenceLoading(text: "consultando a frota…", reduceMotion: reduceMotion)
            Spacer()
        }
    }
}
