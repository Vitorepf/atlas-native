import SwiftUI
import AtlasCore

// Provenance failed state — peel de AtlasCodeProvenanceSections+Content.
// Title → AtlasCodeProvenanceSections+Failed+Title.swift
// Detail → AtlasCodeProvenanceSections+Failed+Detail.swift
// Stack → AtlasCodeProvenanceSections+Failed+Stack.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailed(_ message: String) -> some View {
        provenanceFailedStack(message)
    }
}
