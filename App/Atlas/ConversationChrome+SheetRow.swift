import SwiftUI
import AtlasCore

// Cycle 021 fuse → ConversationChrome+SheetRow.swift

struct SheetRow: View {
    let label: String
    var sub: String? = nil
    let selected: Bool
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil
    var accessibilityIdentifier: String? = nil
    let action: () -> Void
    var body: some View {
        sheetRowA11y
    }
}

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
        .modifier(OptionalAccessibilityIdentifier(id: accessibilityIdentifier))
        .overlay(alignment: .bottom) { sheetRowDivider }
    }
}

extension SheetRow {
    var sheetRowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
    }
}

extension SheetRow {
    var sheetRowLeading: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).atlasSans(17).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let sub {
                Text(sub).atlasSans(13).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension SheetRow {
    @ViewBuilder
    var sheetRowTrailing: some View {
        if selected {
            Image(systemName: "checkmark").atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}

extension SheetRow {
    var rowLabel: some View {
        HStack(spacing: 12) {
            sheetRowLeading
            Spacer()
            sheetRowTrailing
        }
        .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
    }
}
