import SwiftUI
import AtlasCore

// Provenance sheet surface — peel de AtlasCodeProvenanceSheet.

extension AtlasCodeProvenanceSheet {
    var provenanceSurface: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            provenanceScrollStack
        }
    }
}
