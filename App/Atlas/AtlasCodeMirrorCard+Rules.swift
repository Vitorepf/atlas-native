import AtlasCore
import SwiftUI

// Rules blocked — peel de AtlasCodeMirrorCard.

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var blockedRulesRow: some View {
        if case .blocked(let rules) = response.state {
            HStack(spacing: 5) {
                ForEach(rules, id: \.self) { rule in
                    Text(rule)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasCodePalette.alert)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.3), lineWidth: 1))
                        .accessibilityHidden(true)
                }
            }
            .accessibilityHidden(true)
        }
    }
}
