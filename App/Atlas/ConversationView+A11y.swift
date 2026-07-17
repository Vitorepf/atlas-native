import SwiftUI
import UIKit
import AtlasCore

/// Spoken labels e helpers de toast — peel de ConversationView (CICLO C residual honesty).

enum ConversationViewA11y {
    static func spokenToast(_ message: String) -> String { "aviso, \(message)" }

    static func spokenOutlineLabel(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static let outlineHint = "abre o índice editorial dos turnos desta conversa"
    static let headerContinuityLabel = "continuidade da conversa"
    static let headerContinuityHint = "continuar esta conversa no Mac ou no Terminal"
}

extension ConversationView {
    func setToast(_ message: String) {
        if reduceMotion { model.toast = message }
        else { withAnimation(AtlasMotion.editorial) { model.toast = message } }
        UIAccessibility.post(notification: .announcement, argument: ConversationViewA11y.spokenToast(message))
    }

    func clearToast() {
        if reduceMotion { model.toast = nil }
        else { withAnimation(AtlasMotion.editorial) { model.toast = nil } }
    }
}
