import SwiftUI
import AtlasCore

// Gates + obra — peel de AtlasCodeProvenanceSections+Loaded.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceGatesObra(_ provenance: AtlasCodeProvenance) -> some View {
        if let gates = provenance.gates, !gates.isEmpty {
            block("Prova no ledger") { AtlasCodeChipRow(items: gates) }
        }
        if let obra = provenance.obra, !obra.isEmpty {
            block("Obra") { AtlasCodeChipRow(items: obra) }
        }
    }
}
