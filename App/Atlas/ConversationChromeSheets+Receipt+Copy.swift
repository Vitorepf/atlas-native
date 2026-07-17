import SwiftUI
import AtlasCore

// Copy — peel de ConversationHandoffReceipt.
// A11y → ConversationChromeSheets+Receipt+A11y.swift
// Age → ConversationChromeSheets+Receipt+Age.swift
// Subline → ConversationChromeSheets+Receipt+Subline.swift

extension ConversationHandoffReceipt {
    var headline: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        if isReady { return "Pronto no \(dest)" }
        if isPending { return "Enviando para o \(dest)…" }
        return "Continuidade para \(dest)"
    }
}
