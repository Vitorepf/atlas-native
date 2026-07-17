import SwiftUI
import AtlasCore

// Status capsule + semana/recibo — peel de AtlasCodeGraphChrome.

extension AtlasCodeView {
    /// Cápsula central e simétrica: a única voz do estado geral.
    var statusCapsule: some View {
        let cor: Color = {
            switch model.scanState {
            case .violating: return AtlasCodePalette.alert
            case .clean: return AtlasCodePalette.healed
            case .unknown: return AtlasTheme.textTertiary
            }
        }()
        let simbolo: String = {
            switch model.scanState {
            case .violating: return "exclamationmark.triangle"
            case .clean: return "checkmark"
            case .unknown: return "questionmark"
            }
        }()

        return HStack(spacing: 7) {
            Image(systemName: simbolo)
                .font(.system(size: 10, weight: .semibold))
            Text(model.statusHeadline)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(cor)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(Capsule().fill(cor.opacity(0.09)))
        .overlay(Capsule().strokeBorder(cor.opacity(0.35), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
        .accessibilityLabel(AtlasCodeGraphA11y.spokenStatus(
            scanState: model.scanState, headline: model.statusHeadline
        ))
        .accessibilityIdentifier(A11yID.codeStatus)
    }

    func weekMetric(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(String(value))
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}
