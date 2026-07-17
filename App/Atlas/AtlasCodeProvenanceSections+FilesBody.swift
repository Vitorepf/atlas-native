import SwiftUI
import AtlasCore

// Files body — peel de AtlasCodeProvenanceSections+Files.

extension AtlasCodeProvenanceSheet {
    func filesSectionBody(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            filesSectionHeader
            provenanceFilesList(provenance, whyTarget: whyTarget)
        }
    }
}
