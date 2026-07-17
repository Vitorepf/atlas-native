import SwiftUI

// Montagem animada da entrega — só quando o contrato publica provas reais.

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
                Text("·")
                    .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                Text("\(min(mountRevealed, deliveryChecks.count))/\(deliveryChecks.count)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.accent)
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                if !mountComplete {
                    BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                }
                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(mountSpoken)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(deliveryChecks.enumerated()), id: \.element.id) { index, check in
                    if index < mountRevealed {
                        HStack(spacing: 8) {
                            Text(check.label)
                                .font(AtlasFont.mono(10))
                                .foregroundStyle(AtlasTheme.textPrimary)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                            Text(check.status)
                                .font(AtlasFont.mono(10))
                                .foregroundStyle(check.isPassing ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(check.spoken)
                        .accessibilityIdentifier(A11yID.artifactsMountCheck(index))
                        .transition(.opacity.combined(with: .move(edge: .top)))
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

    func runMountAnimation() async {
        guard hasDeliveryProof else {
            mountRevealed = deliveryChecks.count
            return
        }
        if reduceMotion {
            mountRevealed = deliveryChecks.count
            return
        }
        mountRevealed = 0
        for step in 1...deliveryChecks.count {
            try? await Task.sleep(nanoseconds: 280_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(AtlasMotion.editorial) { mountRevealed = step }
        }
    }
}
