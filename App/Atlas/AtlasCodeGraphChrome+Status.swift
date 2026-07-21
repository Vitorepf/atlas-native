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

    /// Uma voz com o model: `statusHeadline` já fala “sem retorno”.
    var statusPulseCopy: String? {
        switch model.scanState {
        case .violating, .unknown:
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
