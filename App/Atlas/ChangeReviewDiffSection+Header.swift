import AtlasCore
import SwiftUI

// Cycle 040 fuse → ChangeReviewDiffSection+Header.swift

extension ChangeReviewPatchCard {
    var patchHeader: some View {
        HStack {
            Text("PATCH \(String(patch.id.prefix(8)))")
                .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Button(diffExpanded ? "Fechar diff" : "Ver diff") { toggleDiff() }
                .font(.system(.footnote, weight: .medium)).foregroundStyle(AtlasTheme.accent)
                .accessibilityLabel(ChangeReviewPatchA11y.spokenDiffToggle(expanded: diffExpanded))
                .accessibilityHint("mostra ou oculta o conteúdo do diff para este patch")
                .accessibilityIdentifier(A11yID.reviewPatchDiff(patch.id))
        }
    }
}
