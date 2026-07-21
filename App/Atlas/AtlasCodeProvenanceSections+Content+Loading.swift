import SwiftUI
import AtlasCore

// Provenance loading content — peel de AtlasCodeProvenanceSections+Content.

extension AtlasCodeProvenanceSheet {
    var provenanceLoadingContent: some View {
        TraceEvidenceLoading(text: "lendo o ledger…", reduceMotion: reduceMotion)
            .padding(.top, 2)
    }
}
