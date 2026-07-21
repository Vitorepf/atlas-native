import SwiftUI

/// Botão canônico Fechar/Cancelar com RM haptic — peel CICLO B (elimina dups).
/// A11yID → AtlasCloseToolbarButton+A11yID.swift

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
