import SwiftUI
import AtlasCore

// Status editorial — peel de AtlasCodeGraphChrome.
// Sem pílula/triângulo. Violação → "N sem retorno". Limpo → silêncio.

extension AtlasCodeView {
    @ViewBuilder
    var statusCapsule: some View {
        if let pulse = statusPulseCopy {
            Text(pulse)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(statusPulseColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 12)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
                .accessibilityLabel(AtlasCodeGraphA11y.spokenStatus(
                    scanState: model.scanState, headline: pulse
                ))
                .accessibilityIdentifier(A11yID.codeStatus)
        }
    }

    /// Copy de apresentação: mesma unidade do model (violations.count),
    /// vocabulário do operador ("sem retorno"), não "desvios".
    var statusPulseCopy: String? {
        switch model.scanState {
        case .violating:
            let n = model.violations?.violations.count ?? 0
            guard n > 0 else { return model.statusHeadline }
            return n == 1 ? "1 sem retorno" : "\(n) sem retorno"
        case .unknown:
            return model.statusHeadline
        case .clean:
            return nil
        }
    }

    var statusPulseColor: Color {
        switch model.scanState {
        case .violating: return AtlasCodePalette.alert
        case .unknown: return AtlasTheme.textTertiary
        case .clean: return AtlasTheme.textSecondary
        }
    }
}
