import SwiftUI
import AtlasCore

/// Submit — peel de ArenaRunSheet (régua ≤100).
/// Defaults → ArenaRunSheet+Defaults.swift
/// Label → ArenaRunSheet+Submit+Label.swift

extension ArenaRunSheet {
    var submitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task { await model.startRuns(input: input) }
        } label: {
            submitButtonLabel
        }
        .buttonStyle(PressableScale())
        .foregroundStyle(input.isLocallyValidForSubmission ? AtlasTheme.accent : AtlasTheme.textTertiary)
        .disabled(!input.isLocallyValidForSubmission)
        .accessibilityIdentifier(A11yID.arenaRunSubmit)
        .accessibilityLabel(spokenSubmitLabel(input: input, enginesEmpty: engines.isEmpty))
        .accessibilityHint(spokenSubmitHint(input: input, enginesEmpty: engines.isEmpty))
    }
}
