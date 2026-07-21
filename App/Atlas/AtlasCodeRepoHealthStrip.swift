import AtlasCore
import SwiftUI

// MARK: - Repo health strip (WAVE-043)

/// Thin exclusive health face for single-repo Código surface.
struct AtlasCodeRepoHealthStrip: View {
    let model: AtlasCodeModel
    let mirror: AtlasCodeMirrorResponse?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: AtlasCodeRepoHealthFace {
        AtlasCodeRepoHealthJudgment.face(model: model, mirror: mirror)
    }

    var body: some View {
        switch face {
        case .unbound:
            EmptyView()
        case .unknown, .clean, .healed, .weekActive, .violating, .mirrorBlocked:
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
                Text(AtlasCodeRepoHealthJudgment.summaryLine(model: model, mirror: mirror))
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.codeRepoHealth)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .mirrorBlocked, .violating: return AtlasCodePalette.alert
        case .healed: return AtlasCodePalette.healed
        case .weekActive: return AtlasTheme.accent
        case .clean: return AtlasTheme.textTertiary
        case .unknown, .unbound: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .mirrorBlocked, .violating: return AtlasCodePalette.alert
        case .healed: return AtlasCodePalette.healed
        case .weekActive: return AtlasTheme.accent
        case .clean, .unknown, .unbound: return AtlasTheme.textTertiary
        }
    }
}
