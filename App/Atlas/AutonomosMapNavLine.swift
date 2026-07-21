import SwiftUI

/// Linha › do mapa Autônomos — tipografia, sem cápsula.
struct AutonomosMapNavLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let meta: String
    var danger: Bool = false
    /// Soft default (nav); medium for governed state commits (e.g. Pausar).
    var haptic: AutonomosMapChrome.CTAHaptic = .soft
    let action: () -> Void

    var body: some View {
        Button {
            switch haptic {
            case .soft: AtlasMotion.softImpact(reduceMotion: reduceMotion)
            case .medium: AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            }
            action()
        } label: {
            HStack(spacing: 10) {
                Text(title)
                    .atlasSans(15.5, .medium)
                    .foregroundStyle(danger ? AtlasTheme.alert : AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !meta.isEmpty {
                    Text(meta)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
                Text("›")
                    .atlasSans(13)
                    .foregroundStyle(danger ? AtlasTheme.alert.opacity(0.7) : AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 14)
            .frame(minHeight: 48, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline.padding(.vertical, 0) }
        .accessibilityLabel(meta.isEmpty ? title : "\(title), \(meta)")
        .accessibilityHint(danger ? "abre confirmação de \(title.lowercased())" : "abre \(title.lowercased())")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosNav(title))
    }
}
