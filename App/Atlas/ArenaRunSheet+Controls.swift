import SwiftUI
import AtlasCore

/// Controles reutilizáveis do sheet de medição Arena — peel de ArenaRunSheet.
extension ArenaRunSheet {
    func receiptCard(_ receipt: AtlasArenaStartReceipt) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("recibo \(receipt.receiptHash)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)
            Text(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
                .font(.system(.callout, weight: .semibold))
                .foregroundStyle(AtlasTheme.accent)
            if receipt.workerImplemented == false {
                Text("worker de medição ainda não implementado")
                    .font(.system(.caption))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenReceiptLabel(receipt))
        .accessibilityIdentifier(A11yID.arenaRunReceipt)
    }

    func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.caption, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
            content()
        }
    }

    func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? AtlasTheme.accent : AtlasTheme.textTertiary)
                    .modifier(ArenaToggleSymbolBounce(enabled: !reduceMotion, isOn: isOn))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textTertiary)
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

struct ArenaToggleSymbolBounce: ViewModifier {
    let enabled: Bool
    let isOn: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.symbolEffect(.bounce, value: isOn)
        } else {
            content
        }
    }
}
