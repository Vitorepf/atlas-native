import SwiftUI

// Montagem animada da entrega — só quando o contrato publica provas reais.
// Checks → ArtifactSheet+MountChecks.swift · Animation → ArtifactSheet+MountAnimation.swift
// Header → ArtifactSheet+MountHeader.swift

extension ArtifactSheet {
    var changeReview: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }
    var deliveryChecks: [ArtifactDeliveryCheck] { ArtifactDeliveryProof.checks(from: changeReview) }
    var hasDeliveryProof: Bool { !deliveryChecks.isEmpty }
    var mountComplete: Bool { !hasDeliveryProof || mountRevealed >= deliveryChecks.count }

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
