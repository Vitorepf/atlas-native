import SwiftUI

/// Linha › do mapa Autônomos — tipografia, sem cápsula.
struct AutonomosMapNavLine: View {
    let title: String
    let meta: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 15.5, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(meta)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                Text("›")
                    .font(.system(size: 13))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline.padding(.vertical, 0) }
    }
}
