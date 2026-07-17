import SwiftUI
import AtlasCore

// Conteúdo carregado da folha de proveniência — peel de AtlasCodeProvenanceSections.
// Loaded → AtlasCodeProvenanceSections+Loaded.swift
// Failed → AtlasCodeProvenanceSections+Failed.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceContent(whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        switch phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo o ledger…", reduceMotion: reduceMotion)
                .padding(.top, 2)
        case .failed(let message):
            provenanceFailed(message)
        case .loaded(let provenance):
            provenanceLoadedBody(provenance, whyTarget: whyTarget)
        }
    }
}
