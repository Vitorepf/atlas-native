import SwiftUI

// Cycle 040 fuse → AtlasCodeLoadFailure+Icon.swift

extension AtlasCodeLoadFailureEmpty {
    var failureIcon: some View {
        Image(systemName: "exclamationmark.triangle")
            .atlasSans(24)
            .foregroundStyle(AtlasCodePalette.alert)
            .accessibilityHidden(true)
    }
}
