import AtlasCore
import SwiftUI

// Cycle 027 fuse → ArtifactSheet+Mount.swift

extension ArtifactSheet {
    @ViewBuilder
    func mountCheckRowTexts(check: ArtifactDeliveryCheck) -> some View {
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
}

extension ArtifactSheet {
    func mountCheckRow(index: Int, check: ArtifactDeliveryCheck) -> some View {
        HStack(spacing: 8) {
            mountCheckRowTexts(check: check)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(check.spoken)
        .accessibilityIdentifier(A11yID.artifactsMountCheck(index))
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var mountChecks: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(deliveryChecks.enumerated()), id: \.element.id) { index, check in
                if index < mountRevealed {
                    mountCheckRow(index: index, check: check)
                }
            }
        }
    }
}

extension ArtifactSheet {
    var mountCounterText: some View {
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
        }
    }
}

extension ArtifactSheet {
    var mountHeaderCounter: some View {
        HStack(spacing: 8) {
            mountCounterText
            if !mountComplete {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }
}

extension ArtifactSheet {
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

extension ArtifactSheet {
    var mountSpoken: String {
        let n = min(mountRevealed, deliveryChecks.count)
        let tail = mountComplete ? "entrega liberada" : "montando provas"
        return "montagem da entrega, prova \(n) de \(deliveryChecks.count), \(tail)"
    }
}

// Montagem animada da entrega — só quando o contrato publica provas reais.

extension ArtifactSheet {
    @ViewBuilder
    var artifactMount: some View {
        artifactMountStack
    }
}

extension ArtifactSheet {
    var mountHeader: some View {
        mountHeaderCounter
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(mountSpoken)
    }
}

extension ArtifactSheet {
    var changeReview: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }
    var deliveryChecks: [ArtifactDeliveryCheck] { ArtifactDeliveryProof.checks(from: changeReview) }
    var hasDeliveryProof: Bool { !deliveryChecks.isEmpty }
    var mountComplete: Bool { !hasDeliveryProof || mountRevealed >= deliveryChecks.count }
}

extension ArtifactSheet {
    var artifactMountStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            mountHeader
            mountChecks
        }
        .padding(14)
        .atlasCard()
        .accessibilityIdentifier(A11yID.artifactsMount)
    }
}

extension ArtifactDeliveryCheck {
    var isPassing: Bool {
        let s = status.lowercased()
        return s == "pass" || s == "passed"
    }

    var spoken: String { "\(label), status \(status)" }
}

// Provas de montagem — só controles/testes reais do contrato C15 (nunca inventa 0/3).

struct ArtifactDeliveryCheck: Identifiable, Equatable {
    let id: String
    let label: String
    let status: String
}

enum ArtifactDeliveryProof {
    /// Controles + testRuns publicados na revisão trace-scoped — vazio = silêncio na montagem.
    static func checks(from review: AtlasTraceChangeReview?) -> [ArtifactDeliveryCheck] {
        guard review?.state == .available, let review else { return [] }
        let controls = review.controls.map {
            ArtifactDeliveryCheck(id: "control-\($0.id)", label: $0.slug, status: $0.status)
        }
        let tests = review.testRuns.map {
            ArtifactDeliveryCheck(id: "test-\($0.id)", label: $0.command ?? "teste", status: $0.status)
        }
        return controls + tests
    }
}
