import AtlasCore
import SwiftUI

// Linhas de repositório e pasta do radar — peel de AtlasCodeRadarSections.
// Label → AtlasCodeRadarRows+Label.swift
// A11y chrome → AtlasCodeRadarRows+A11yChrome.swift

struct AtlasCodeRepoRow: View {
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
    /// A trunk real deste repo: a frase da issue fala o nome da linha.
    var trunk: String? = nil
    /// Nos recentes a pasta situa; dentro da pasta seria redundante.
    let showsFolder: Bool
    let onTap: () -> Void

    var body: some View {
        repoRowA11yChrome
    }
}
