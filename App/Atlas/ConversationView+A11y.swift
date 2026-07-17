import SwiftUI
import UIKit
import AtlasCore

/// Spoken labels e helpers de toast — peel de ConversationView (CICLO C residual honesty).
/// Toast → ConversationView+A11yToast.swift
/// Screen → ConversationView+A11yScreen.swift

enum ConversationViewA11y {
    static func spokenToast(_ message: String) -> String { "aviso, \(message)" }

    static func spokenOutlineLabel(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static let outlineHint = "abre o índice editorial dos turnos desta conversa"
    static let headerContinuityLabel = "continuidade da conversa"
    static let headerContinuityHint = "continuar esta conversa no Mac ou no Terminal"
    static let screenHint = "turnos e composer só com dados da sessão e do model"
}
