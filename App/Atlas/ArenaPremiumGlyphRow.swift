import SwiftUI

/// Linha operacional com glifo tipográfico (∥ ※ ⌖ ◷) — alfabeto quiet luxury.
/// Sem caixinha SF Symbol de template.
struct ArenaPremiumGlyphRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let glyph: String
    let title: String
    let detail: String
    var tone: ArenaPremiumTone = .neutral
    var glyphTone: ArenaPremiumTone? = nil
    let action: () -> Void

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
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
                    .accessibilityHidden(true)
                Text("›")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(detail)")
        .accessibilityHint("abre \(title.lowercased())")
        .accessibilityAddTraits(.isButton)
    }
}
