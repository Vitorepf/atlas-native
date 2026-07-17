import AtlasCore
import SwiftUI

/// M5 · Espelho — o que sairia do Mac, e o que a varredura encontrou.
/// Rules → AtlasCodeMirrorCard+Rules.swift
struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Espelho")
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer()
                if let host = response.mirror?.host {
                    Text(host)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            headline
            blockedRulesRow
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(borderColor, lineWidth: 1))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: mirrorStatePhaseID)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMirrorLabel())
        .accessibilityHint(Self.mirrorHint)
        .accessibilityIdentifier(A11yID.codeMirror)
    }
}
