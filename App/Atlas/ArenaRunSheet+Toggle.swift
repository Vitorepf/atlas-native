import SwiftUI
import AtlasCore

// Toggle row — peel de ArenaRunSheet+Controls.

extension ArenaRunSheet {
    func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? AtlasTheme.accent : AtlasTheme.textTertiary)
                    .modifier(ArenaToggleSymbolBounce(enabled: !reduceMotion, isOn: isOn))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                    if let subtitle {
                        Text(subtitle)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .accessibilityHidden(true)
                    }
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(toggleAccessibilityLabel(title: title, subtitle: subtitle, isOn: isOn))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    func toggleAccessibilityLabel(title: String, subtitle: String?, isOn: Bool) -> String {
        let state = isOn ? "selecionado" : "não selecionado"
        if let subtitle { return "\(title), \(subtitle), \(state)" }
        return "\(title), \(state)"
    }
}
