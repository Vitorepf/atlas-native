import SwiftUI
import AtlasCore

// Header ARQUIVOS — peel de AtlasCodeProvenanceSections+Files.

extension AtlasCodeProvenanceSheet {
    var filesSectionHeader: some View {
        Text("ARQUIVOS")
            .atlasSans(8.5, .semibold)
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(A11yID.codeCommitFiles)
    }
}
