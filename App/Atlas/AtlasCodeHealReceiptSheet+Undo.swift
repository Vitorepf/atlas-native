import SwiftUI
import AtlasCore

// Undo button — peel de AtlasCodeHealReceiptSheet+Chrome.

extension AtlasCodeHealReceiptSheet {
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
