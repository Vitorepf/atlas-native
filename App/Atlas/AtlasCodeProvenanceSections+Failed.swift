import SwiftUI
import AtlasCore

// Provenance failed state — peel de AtlasCodeProvenanceSections+Content.
// Title → AtlasCodeProvenanceSections+Failed+Title.swift
// Detail → AtlasCodeProvenanceSections+Failed+Detail.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailed(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            provenanceFailedTitle
            provenanceFailedDetail(message)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenFailed(message))
    }
}
