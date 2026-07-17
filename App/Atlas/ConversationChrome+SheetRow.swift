import SwiftUI

struct SheetRow: View {
    let label: String
    var sub: String? = nil
    let selected: Bool
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil
    var accessibilityIdentifier: String? = nil
    let action: () -> Void
    var body: some View {
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
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}
