import SwiftUI
import AtlasCore

// Arquivos — peel de AtlasCodeProvenanceSections+Content.
// Quote → AtlasCodeProvenanceSections+PullQuote.swift
// List → AtlasCodeProvenanceSections+FilesList.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func filesSection(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        if !provenance.files.isEmpty {
            VStack(alignment: .leading, spacing: 9) {
                Text("ARQUIVOS")
                    .font(.system(size: 8.5, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier(A11yID.codeCommitFiles)

                provenanceFilesList(provenance, whyTarget: whyTarget)
            }
        }
    }
}
