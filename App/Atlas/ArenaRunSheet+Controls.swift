import AtlasCore
import SwiftUI

// Cycle 026 fuse → ArenaRunSheet+Controls.swift

extension ArenaRunSheet {
    func receiptCard(_ receipt: AtlasArenaStartReceipt) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            receiptCardCopy(receipt)
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenReceiptLabel(receipt))
        .accessibilityIdentifier(A11yID.arenaRunReceipt)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptHashCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text("recibo \(receipt.receiptHash)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(1)
            .truncationMode(.middle)
            .accessibilityHidden(true)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptStatusCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
            .font(.system(.callout, weight: .semibold))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptWorkerGapCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        if receipt.workerImplemented == false {
            // false hoje = worker desligado no servidor (ATLAS_ARENA_WORKER_ENABLED).
            Text("worker de medição desligado no servidor — fila aguardando")
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptCardCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        receiptHashCopy(receipt)
        receiptStatusCopy(receipt)
        receiptMultiEngineCopy
        receiptWorkerGapCopy(receipt)
    }

    /// Agregado do start multi-motor (goal 1) — só quando houve 2+ POSTs.
    @ViewBuilder
    var receiptMultiEngineCopy: some View {
        if model.lastStartEnginesCount > 1 {
            Text("\(model.lastStartEnginesCount) motores · \(model.lastStartRunsPlannedTotal) runs na fila")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ArenaRunSheet {
    func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            toggleLabel(title: title, subtitle: subtitle, isOn: isOn)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(toggleAccessibilityLabel(title: title, subtitle: subtitle, isOn: isOn))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

extension ArenaRunSheet {
    func toggleAccessibilityLabel(title: String, subtitle: String?, isOn: Bool) -> String {
        let state = isOn ? "selecionado" : "não selecionado"
        if let subtitle { return "\(title), \(subtitle), \(state)" }
        return "\(title), \(state)"
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelSymbol(isOn: Bool) -> some View {
        ArenaPremiumIcon(
            symbol: isOn ? "checkmark.circle" : "circle",
            tone: isOn ? .active : .muted
        )
            .modifier(ArenaToggleSymbolBounce(enabled: !reduceMotion, isOn: isOn))
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelTitleStack(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            toggleSubtitle(subtitle)
        }
    }
}

extension ArenaRunSheet {
    func toggleLabel(title: String, subtitle: String?, isOn: Bool) -> some View {
        HStack(spacing: 10) {
            toggleLabelSymbol(isOn: isOn)
            toggleLabelTitleStack(title: title, subtitle: subtitle)
            Spacer()
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleSubtitle(_ subtitle: String?) -> some View {
        if let subtitle {
            Text(subtitle)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
