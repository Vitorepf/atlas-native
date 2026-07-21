import AtlasCore
import SwiftUI

// MARK: - Status capsule + labels do radar

/// Silêncio = produto: clean → caption quieta; alarme só com violação real.
struct AtlasCodeRadarStatusCapsule: View {
    let model: AtlasCodeWorkspaceModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group {
            switch model.scanState {
            case .clean, .unknown:
                Text(model.scanState == .clean ? "código" : model.headline)
                    .atlasSans(11, .semibold)
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.vertical, 7)
                    .accessibilityHidden(true)
            case .violating:
                HStack(spacing: 7) {
                    Image(systemName: "exclamationmark.triangle")
                        .atlasSans(10, .semibold)
                        .accessibilityHidden(true)
                    Text(model.headline)
                        .atlasSans(11, .semibold)
                        .monospacedDigit()
                        .accessibilityHidden(true)
                }
                .foregroundStyle(AtlasCodePalette.alert)
                .padding(.horizontal, 15)
                .padding(.vertical, 7)
                .background(Capsule().fill(AtlasCodePalette.alert.opacity(0.09)))
                .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.35), lineWidth: 1))
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: model.scanState)
        .frame(maxWidth: .infinity, minHeight: 36, alignment: .center)
        .accessibilityLabel(spokenStatus)
        .accessibilityAddTraits(model.scanState == .violating ? .isHeader : [])
        .accessibilityIdentifier(A11yID.radarStatus)
    }

    /// Frota quieta = caption mínima; alarme só com violação verificada no scan.
    private var spokenStatus: String {
        switch model.scanState {
        case .clean:
            return "código quieto, nada pede você"
        case .unknown:
            return model.headline
        case .violating:
            return "atenção, \(model.headline)"
        }
    }
}

struct AtlasCodeRadarSectionLabel: View {
    let text: String
    var accessibilityID: String? = nil

    var body: some View {
        Text(text)
            .atlasSans(10, .semibold)
            .tracking(1.3)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(accessibilityID ?? text)
    }
}

struct AtlasCodeRadarRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.5))
            .frame(height: 0.5)
    }
}
