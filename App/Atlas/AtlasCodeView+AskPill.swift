import SwiftUI
import AtlasCore

// Pílula de pergunta — peel de AtlasCodeView+Graph (régua ~160).
// Clear → AtlasCodeView+AskPillClear.swift · Content → +AskPillContent.swift
// Chrome → AtlasCodeView+AskPillChrome.swift

extension AtlasCodeView {
    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
    var askPill: some View {
        askPillChrome
    }
}
