import SwiftUI
import AtlasCore

// Lifecycle + a11y — peel de AtlasCodeWhySheet.

extension AtlasCodeWhySheet {
    func whyLifecycleA11y<V: View>(_ content: V) -> some View {
        content
            .task { if model.phase == .idle { await model.load(repo: repo, file: file) } }
            .accessibilityIdentifier(A11yID.whySheet)
            .accessibilityLabel(whySheetSpokenLabel)
            .accessibilityHint(Self.sheetHint)
    }
}
