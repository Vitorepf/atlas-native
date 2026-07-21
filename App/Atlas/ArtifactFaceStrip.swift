import AtlasCore
import SwiftUI

// MARK: - Artifact face strip (WAVE-041)

/// Thin exclusive evidence face for Artefatos sheet.
struct ArtifactFaceStrip: View {
    let artifacts: AtlasTraceArtifacts?
    let deliveryChecks: [ArtifactDeliveryCheck]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: ArtifactEvidenceFace {
        ArtifactJudgment.face(artifacts: artifacts, deliveryChecks: deliveryChecks)
    }

    var body: some View {
        switch face {
        case .absent:
            EmptyView()
        case .unavailable, .empty, .ready, .deliveryPressure:
            stripChrome
        }
    }

    private var stripChrome: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(face.kicker)
                    .font(AtlasFont.mono(9))
                    .tracking(0.7)
                    .foregroundStyle(titleColor)
                Text(ArtifactJudgment.summaryLine(
                    artifacts: artifacts,
                    deliveryChecks: deliveryChecks
                ))
                .font(AtlasFont.serif(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.artifactsFace)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .deliveryPressure: return AtlasTheme.domOperacional
        case .ready: return AtlasTheme.domAutonomos
        case .empty, .unavailable: return AtlasTheme.textTertiary
        case .absent: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .deliveryPressure: return AtlasTheme.domOperacional
        case .ready: return AtlasTheme.domAutonomos
        case .empty, .unavailable, .absent: return AtlasTheme.textTertiary
        }
    }
}
