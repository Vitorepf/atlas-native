import SwiftUI
import AtlasCore

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)

struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    let onUndo: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
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

                if hasCompletedHeal {
                    Text("você não foi necessário")
                        .font(AtlasFont.serif(20, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel(spokenSilenceLabel())
                }

                if let blocked = heal.blocked, !blocked.isEmpty {
                    Text("bloqueado · \(blocked)")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasCodePalette.alert)
                        .accessibilityLabel(spokenBlockedLabel(blocked))
                }

                if heal.stepReceipts.isEmpty {
                    Text("sem passos registrados no recibo")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityLabel(spokenEmptyStepsLabel())
                } else {
                    stepsBlock()
                }

                if let note = AtlasCodeUndoWindow.note(expiresAt: undoExpiresAt) {
                    Text(note)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityIdentifier(A11yID.codeHealUndoWindow)
                        .accessibilityLabel(spokenUndoWindowLabel(note))
                }
                if canUndo {
                    Button {
                        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
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

                Spacer(minLength: 0)
            }
            .padding(22)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: canUndo)
        }
        .accessibilityIdentifier(A11yID.codeHealReceiptSheet)
        .accessibilityLabel(spokenSheetLabel())
    }
}
