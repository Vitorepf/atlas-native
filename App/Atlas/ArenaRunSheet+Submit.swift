import SwiftUI
import AtlasCore

/// Submit — peel de ArenaRunSheet (régua ≤100).
/// Defaults → ArenaRunSheet+Defaults.swift

extension ArenaRunSheet {
    var submitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task { await model.startRuns(input: input) }
        } label: {
            Text("Rodar medição")
                .font(.system(.body, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(input.isLocallyValidForSubmission ? AtlasTheme.goldVeil : AtlasTheme.surfaceHi))
                .overlay(Capsule().stroke(input.isLocallyValidForSubmission ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(PressableScale())
        .foregroundStyle(input.isLocallyValidForSubmission ? AtlasTheme.accent : AtlasTheme.textTertiary)
        .disabled(!input.isLocallyValidForSubmission)
        .accessibilityIdentifier(A11yID.arenaRunSubmit)
        .accessibilityLabel(spokenSubmitLabel(input: input, enginesEmpty: engines.isEmpty))
        .accessibilityHint(spokenSubmitHint(input: input, enginesEmpty: engines.isEmpty))
    }
}
