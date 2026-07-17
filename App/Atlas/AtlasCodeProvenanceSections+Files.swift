import SwiftUI
import AtlasCore

// Arquivos — peel de AtlasCodeProvenanceSections+Content.
// Quote → AtlasCodeProvenanceSections+PullQuote.swift
// List → AtlasCodeProvenanceSections+FilesList.swift
// Header → AtlasCodeProvenanceSections+FilesHeader.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func filesSection(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        if !provenance.files.isEmpty {
            VStack(alignment: .leading, spacing: 9) {
                filesSectionHeader
                provenanceFilesList(provenance, whyTarget: whyTarget)
            }
        }
    }
}
