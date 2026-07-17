import AtlasCore
import SwiftUI

// Card chrome — peel de AtlasCodeMirrorCard.

extension AtlasCodeMirrorCard {
    var mirrorCardChrome: some View {
        VStack(alignment: .leading, spacing: 8) {
            mirrorHeader
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
