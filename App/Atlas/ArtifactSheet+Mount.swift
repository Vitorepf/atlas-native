import SwiftUI

// Montagem animada da entrega — só quando o contrato publica provas reais.
// Checks → ArtifactSheet+MountChecks.swift · Animation → ArtifactSheet+MountAnimation.swift
// Header → ArtifactSheet+MountHeader.swift
// Predicates → ArtifactSheet+MountPredicates.swift
// Stack → ArtifactSheet+MountStack.swift

extension ArtifactSheet {
    @ViewBuilder
    var artifactMount: some View {
        artifactMountStack
    }
}
