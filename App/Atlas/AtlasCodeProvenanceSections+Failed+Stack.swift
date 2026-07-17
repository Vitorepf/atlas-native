import SwiftUI
import AtlasCore

// Failed stack — peel de AtlasCodeProvenanceSections+Failed.
// Body → AtlasCodeProvenanceSections+Failed+Stack+Body.swift
// A11y → AtlasCodeProvenanceSections+Failed+Stack+A11y.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedStack(_ message: String) -> some View {
        provenanceFailedA11y(provenanceFailedBody(message), message: message)
    }
}
