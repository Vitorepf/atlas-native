import SwiftUI
import AtlasCore

// Masthead + undo — peel de AtlasCodeHealReceiptSheet+Content.

extension AtlasCodeHealReceiptSheet {
    var masthead: some View {
        HStack(spacing: 7) {
            Image(systemName: hasCompletedHeal ? "checkmark" : "exclamationmark.triangle")
                .font(.system(size: 10, weight: .bold))
                .accessibilityHidden(true)
            Text(hasCompletedHeal
                 ? "CURADO SOZINHO · \(heal.mode.uppercased())"
                 : "CURA · \(heal.mode.uppercased())")
                .font(.system(size: 9, weight: .bold))
                .tracking(1.2)
                .accessibilityHidden(true)
        }
        .foregroundStyle(hasCompletedHeal ? AtlasCodePalette.healed : AtlasTheme.textTertiary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMastheadLabel())
    }

    var undoButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onUndo()
            dismiss()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "arrow.uturn.backward")
                    .accessibilityHidden(true)
                Text("Desfazer — com recibo")
            }
            .font(.system(size: 14, weight: .medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(AtlasTheme.textSecondary)
            .atlasCard(cornerRadius: 13)
        }
        .buttonStyle(PressableScale())
        .transition(reduceMotion ? .identity : .opacity)
        .accessibilityIdentifier(A11yID.codeHealUndo)
        .accessibilityLabel(spokenUndoButtonLabel())
        .accessibilityHint(spokenUndoButtonHint())
    }
}
