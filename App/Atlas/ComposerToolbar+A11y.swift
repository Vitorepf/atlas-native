import SwiftUI
import AtlasCore

// Spoken labels do composer — peel de ComposerToolbar (CICLO C residual honesty).
// Input → ComposerToolbar+A11yInput.swift
// Hint → ComposerToolbar+A11yHint.swift

extension ComposerToolbar {
    var isExecuting: Bool { model.isSending || liveBubble != nil }

    func spokenSendLabel(canSubmit: Bool) -> String {
        if canSubmit {
            return isExecuting ? "adicionar à fila" : "enviar ao Atlas"
        }
        return isExecuting
            ? "enviar indisponível, Atlas processando"
            : "enviar indisponível, sem mensagem nem anexo"
    }
}
