import AtlasCore
import SwiftUI

/// M5 · Espelho — o que sairia do Mac, e o que a varredura encontrou.
struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Espelho")
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                if let host = response.mirror?.host {
                    Text(host)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            headline
            if case .blocked(let rules) = response.state {
                HStack(spacing: 5) {
                    ForEach(rules, id: \.self) { rule in
                        Text(rule)
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasCodePalette.alert)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.3), lineWidth: 1))
                    }
                }
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(borderColor, lineWidth: 1))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: mirrorStatePhaseID)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenMirrorLabel())
        .accessibilityHint(Self.mirrorHint)
        .accessibilityIdentifier(A11yID.codeMirror)
    }
}
