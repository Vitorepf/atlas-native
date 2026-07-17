import SwiftUI
import AtlasCore

// Loaded body — peel de AtlasCodeProvenanceSections+Content.
// Block → AtlasCodeProvenanceSections+Block.swift
// Prose → AtlasCodeProvenanceSections+LoadedProse.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceLoadedBody(_ provenance: AtlasCodeProvenance, whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        if hasLoadedBody(provenance) {
            VStack(alignment: .leading, spacing: 18) {
                provenanceProseBlocks(provenance)

                if let gates = provenance.gates, !gates.isEmpty {
                    block("Prova no ledger") { AtlasCodeChipRow(items: gates) }
                }
                if let obra = provenance.obra, !obra.isEmpty {
                    block("Obra") { AtlasCodeChipRow(items: obra) }
                }

                filesSection(provenance, whyTarget: whyTarget)
            }
        }
    }
}
