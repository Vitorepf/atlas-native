import SwiftUI
import AtlasCore

// Ficha do artefato — peel de ArtifactViewer.
// NameStack → ArtifactFileFicha+NameStack.swift
// A11yBind → ArtifactFileFicha+A11yBind.swift

struct ArtifactFileFicha: View {
    let name: String
    let subtitle: String

    var body: some View {
        fichaA11yBind(fichaNameStack)
    }
}
