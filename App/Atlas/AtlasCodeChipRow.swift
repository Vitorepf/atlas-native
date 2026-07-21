import SwiftUI
import AtlasCore

// Chip row — peel de AtlasCodePalette.

struct AtlasCodeChipRow: View {
    let items: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasCodePalette.healed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(minHeight: 28)
                    .overlay(
                        Capsule().strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(items.joined(separator: ", "))
    }
}
