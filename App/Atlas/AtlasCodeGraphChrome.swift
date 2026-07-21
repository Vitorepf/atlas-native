import SwiftUI
import AtlasCore

// WAVE-156 density peel — graph chrome host (status)

extension AtlasCodeView {
    // MARK: Status

    @ViewBuilder
    var statusCapsule: some View {
        if let pulse = statusPulseCopy {
            Text(pulse)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(statusPulseColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 12)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
                .accessibilityLabel(AtlasCodeGraphJudgment.spokenStatus(
                    scanState: model.scanState, headline: pulse
                ))
                .accessibilityIdentifier(A11yID.codeStatus)
        }
    }

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
