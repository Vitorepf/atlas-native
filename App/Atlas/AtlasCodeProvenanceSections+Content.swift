import SwiftUI
import AtlasCore

// Conteúdo carregado da folha de proveniência — peel de AtlasCodeProvenanceSections.
// Loaded → AtlasCodeProvenanceSections+Loaded.swift
// Failed → AtlasCodeProvenanceSections+Failed.swift
// Loading → AtlasCodeProvenanceSections+Content+Loading.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceContent(whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        switch phase {
        case .idle, .loading:
            provenanceLoadingContent
        case .failed(let message):
            provenanceFailed(message)
        case .loaded(let provenance):
            provenanceLoadedBody(provenance, whyTarget: whyTarget)
        }
    }
}
