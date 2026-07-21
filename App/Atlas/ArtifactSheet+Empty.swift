import SwiftUI
import AtlasCore

// Empty / unavailable — peel de ArtifactSheet+Content.
// Gate → ArtifactSheet+EmptyGate.swift
// Unavailable → ArtifactSheet+Unavailable.swift

extension ArtifactSheet {
    @ViewBuilder
    var emptyOrUnavailable: some View {
        if !loadFinished, artifacts == nil {
            TraceEvidenceLoading(text: "consultando artefatos…", reduceMotion: reduceMotion)
        } else if loadFinished, artifacts == nil {
            TraceEvidenceUnavailable(
                title: "Não foi possível consultar artefatos.",
                subtitle: "feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.artifactsLoadFailure,
                spoken: "não foi possível consultar artefatos"
            )
        } else {
            artifactsUnavailable
        }
    }
}
