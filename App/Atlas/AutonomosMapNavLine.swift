import SwiftUI

/// Linha › do mapa Autônomos — tipografia, sem cápsula.
struct AutonomosMapNavLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let meta: String
    let action: () -> Void

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 15.5, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !meta.isEmpty {
                    Text(meta)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
                Text("›")
                    .font(.system(size: 13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 14)
            .frame(minHeight: 48, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline.padding(.vertical, 0) }
        .accessibilityLabel(meta.isEmpty ? title : "\(title), \(meta)")
        .accessibilityHint("abre \(title.lowercased())")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosNav(title))
    }
}
