import SwiftUI

// Montagem animada da entrega — só quando o contrato publica provas reais.
// Checks → ArtifactSheet+MountChecks.swift · Animation → ArtifactSheet+MountAnimation.swift
// Header → ArtifactSheet+MountHeader.swift
// Predicates → ArtifactSheet+MountPredicates.swift

extension ArtifactSheet {
    @ViewBuilder
    var artifactMount: some View {
        VStack(alignment: .leading, spacing: 10) {
            mountHeader
            mountChecks
        }
        .padding(14)
        .atlasCard()
        .accessibilityIdentifier(A11yID.artifactsMount)
    }
}
