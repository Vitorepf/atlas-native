import AtlasCore
import SwiftUI

// Radar loading content — peel de AtlasCodeRadarView+Content.

extension AtlasCodeRadarView {
    var radarLoadingContent: some View {
        TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(A11yID.radarLoading)
    }
}
