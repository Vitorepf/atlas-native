import SwiftUI
import AtlasCore

// Loaded body — peel de AtlasCodeProvenanceSections+Content.
// Gates/Obra → AtlasCodeProvenanceSections+Loaded+GatesObra.swift
// Block → AtlasCodeProvenanceSections+Block.swift
// Prose → AtlasCodeProvenanceSections+LoadedProse.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceLoadedBody(_ provenance: AtlasCodeProvenance, whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        if hasLoadedBody(provenance) {
            VStack(alignment: .leading, spacing: 18) {
                provenanceProseBlocks(provenance)
                provenanceGatesObra(provenance)
                filesSection(provenance, whyTarget: whyTarget)
            }
        }
    }
}
