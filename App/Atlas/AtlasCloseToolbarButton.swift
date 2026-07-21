import SwiftUI

// Cycle 044 fuse → AtlasCloseToolbarButton.swift

struct AtlasCloseToolbarButton: View {
    var title: String = "Fechar"
    let spokenLabel: String
    var spokenHint: String = ""
    var accessibilityID: String? = nil
    let reduceMotion: Bool
    let action: () -> Void

    var body: some View {
        Button(title) {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        }
        // Dispensar nunca é acento: Fechar/Cancelar fala ink neutro (canon §C).
        .tint(AtlasTheme.textSecondary)
        .accessibilityLabel(spokenLabel)
        .accessibilityHint(spokenHint)
        .modifier(CloseToolbarA11yID(accessibilityID))
    }
}

struct CloseToolbarA11yID: ViewModifier {
    let id: String?
    init(_ id: String?) { self.id = id }
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}
