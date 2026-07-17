import SwiftUI
import AtlasCore

// Filter chip — peel de RootHomeSections+Chips.
// Label → RootHomeSections+ChipLabel.swift

extension RootHomeSections {
    func homeFilterChip(_ label: String, key: String?) -> some View {
        let active = homeWorkspaceFilter == key
        return Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            homeWorkspaceFilter = key
        } label: {
            homeFilterChipLabel(label, active: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(filterChipSpokenLabel(label, active: active))
        .accessibilityHint("altera o filtro de conversas na lista abaixo")
        .accessibilityAddTraits(active ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier(A11yID.homeWorkspaceChip(key ?? "__free"))
    }
}
