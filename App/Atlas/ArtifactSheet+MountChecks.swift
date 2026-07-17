import SwiftUI
import AtlasCore

// Checks revelados — peel de ArtifactSheet+Mount.

extension ArtifactSheet {
    @ViewBuilder
    var mountChecks: some View {
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

    var mountSpoken: String {
        let n = min(mountRevealed, deliveryChecks.count)
        let tail = mountComplete ? "entrega liberada" : "montando provas"
        return "montagem da entrega, prova \(n) de \(deliveryChecks.count), \(tail)"
    }
}
