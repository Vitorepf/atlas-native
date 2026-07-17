import SwiftUI
import AtlasCore

// Provenance sheet bind — peel de AtlasCodeView+Sheets+Provenance.
// Content → AtlasCodeView+Sheets+ProvenanceBind+Content.swift
// Present → AtlasCodeView+Sheets+ProvenanceBind+Present.swift

extension AtlasCodeSheetsModifier {
    @ViewBuilder
    func provenanceSheetBind<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $selectedNode) { node in
                provenanceSheetPresent(provenanceSheetContent(for: node))
            }
    }
}
