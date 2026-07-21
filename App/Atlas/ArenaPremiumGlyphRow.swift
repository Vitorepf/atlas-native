import SwiftUI

/// Linha operacional com glifo tipográfico (∥ ※ ⌖ ◷) — alfabeto quiet luxury.
/// Sem caixinha SF Symbol de template.
struct ArenaPremiumGlyphRow: View {
    let glyph: String
    let title: String
    let detail: String
    var tone: ArenaPremiumTone = .neutral
    var glyphTone: ArenaPremiumTone? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(glyph)
                    .font(AtlasFont.serif(14))
                    .foregroundStyle((glyphTone ?? tone).color)
                    .frame(width: 22, alignment: .center)
                    .accessibilityHidden(true)
                Text(title)
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                Text("›")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
