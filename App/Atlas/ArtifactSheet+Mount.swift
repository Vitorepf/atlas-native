import SwiftUI

// Montagem animada da entrega — só quando o contrato publica provas reais.
// Animation → ArtifactSheet+MountAnimation.swift

extension ArtifactSheet {
    var changeReview: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }
    var deliveryChecks: [ArtifactDeliveryCheck] { ArtifactDeliveryProof.checks(from: changeReview) }
    var hasDeliveryProof: Bool { !deliveryChecks.isEmpty }
    var mountComplete: Bool { !hasDeliveryProof || mountRevealed >= deliveryChecks.count }

    @ViewBuilder
    var artifactMount: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("MONTAGEM")
                    .font(AtlasFont.mono(10)).tracking(1.0)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text("·")
                    .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text("\(min(mountRevealed, deliveryChecks.count))/\(deliveryChecks.count)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.accent)
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                    .accessibilityHidden(true)
                if !mountComplete {
                    BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                        .accessibilityHidden(true)
                }
                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(mountSpoken)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(deliveryChecks.enumerated()), id: \.element.id) { index, check in
                    if index < mountRevealed {
                        HStack(spacing: 8) {
                            Text(check.label)
                                .font(AtlasFont.mono(10))
                                .foregroundStyle(AtlasTheme.textPrimary)
                                .lineLimit(1)
                                .accessibilityHidden(true)
                            Spacer(minLength: 0)
                            Text(check.status)
                                .font(AtlasFont.mono(10))
                                .foregroundStyle(check.isPassing ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                                .accessibilityHidden(true)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(check.spoken)
                        .accessibilityIdentifier(A11yID.artifactsMountCheck(index))
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityIdentifier(A11yID.artifactsMount)
    }

    var mountSpoken: String {
        let n = min(mountRevealed, deliveryChecks.count)
        let tail = mountComplete ? "entrega liberada" : "montando provas"
        return "montagem da entrega, prova \(n) de \(deliveryChecks.count), \(tail)"
    }
}
