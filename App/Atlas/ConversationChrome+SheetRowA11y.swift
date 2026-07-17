import SwiftUI

// A11y shell do SheetRow — peel de ConversationChrome+SheetRow.

extension SheetRow {
    var sheetRowA11y: some View {
        Button(action: action) {
            rowLabel
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            accessibilityLabel ?? SheetShellA11y.spokenRow(label: label, sub: sub, selected: selected)
        )
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .modifier(OptionalAccessibilityIdentifier(accessibilityIdentifier))
        .overlay(alignment: .bottom) { sheetRowDivider }
    }
}
