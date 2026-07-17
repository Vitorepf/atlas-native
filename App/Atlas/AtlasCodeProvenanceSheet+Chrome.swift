import SwiftUI
import AtlasCore

// Provenance sheet chrome — peel de AtlasCodeProvenanceSheet.

extension AtlasCodeProvenanceSheet {
    func provenanceSheetChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(provenanceSheetSpokenLabel)
            .accessibilityHint(Self.sheetHint)
            .sheet(item: $whyTarget) { target in
                AtlasCodeWhySheet(client: client, repo: repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}
