import SwiftUI
import AtlasCore

// Commit row a11y chrome — peel de AtlasCodeCommitRow.

extension AtlasCodeCommitRow {
    var commitRowA11yChrome: some View {
        Button(action: onTap) {
            commitRowLabel
        }
        .buttonStyle(.plain)
        .opacity(isDimmed ? 0.26 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: isDimmed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AtlasCodeCommitRowA11y.spokenCommitRow(
                node: node, state: state, trunk: trunk, ruleId: ruleId, isDimmed: isDimmed
            )
        )
        .accessibilityHint(commitAccessibilityHint)
        .accessibilityIdentifier(A11yID.codeCommit(hashPrefix: String(node.hash.prefix(8))))
        .onLongPressGesture(minimumDuration: 0.45, perform: commitLongPress)
    }
}
