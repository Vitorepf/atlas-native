import SwiftUI

// Ícone da falha — peel de AtlasCodeLoadFailure.
// Headline → AtlasCodeLoadFailure+Headline.swift
// Message → AtlasCodeLoadFailure+Message.swift

extension AtlasCodeLoadFailureEmpty {
    var failureIcon: some View {
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 24))
            .foregroundStyle(AtlasCodePalette.alert)
            .accessibilityHidden(true)
    }
}
