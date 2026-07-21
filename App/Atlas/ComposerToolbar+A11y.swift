import AtlasCore
import SwiftUI

// Cycle 030 fuse → ComposerToolbar+A11y.swift

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

extension ComposerToolbar {
    func spokenSendHint(canSubmit: Bool) -> String {
        canSubmit ? spokenSendHintReady() : spokenSendHintBlocked()
    }
}

extension ComposerToolbar {
    func spokenEffortLightLabel(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "esforço automático, Atlas Decide escolhe"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        default: return nil
        }
    }
}

extension ComposerToolbar {
    func spokenEffortLabel(_ effort: AtlasComputeEffort) -> String {
        if let light = spokenEffortLightLabel(effort) { return light }
        switch effort {
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        default: return "esforço automático, Atlas Decide escolhe"
        }
    }
}

extension ComposerToolbar {
    func spokenEffortHint() -> String {
        "abre opções de esforço computacional para o próximo envio"
    }

    func spokenOptionsHint() -> String {
        "modo, esforço e workspace; \(spokenSendHint(canSubmit: false).lowercased())"
    }
}

extension ComposerToolbar {
    func spokenInputLabel() -> String {
        model.bubbles.isEmpty ? "mensagem para o Atlas" : "continuar conversa com o Atlas"
    }

    func spokenInputHint() -> String {
        if canSubmit {
            return isExecuting ? "texto para a fila do próximo turno" : "texto do próximo envio"
        }
        return "escreva aqui para habilitar o envio"
    }
}

extension ComposerToolbar {
    func spokenProcessingLabel() -> String { "Atlas processando" }
}

extension ComposerToolbar {
    func spokenSendHintBlocked() -> String {
        if isExecuting {
            return "escreva uma mensagem para adicionar à fila durante a execução"
        }
        if !model.drafts.isEmpty {
            return "adicione texto ou envie os anexos prontos"
        }
        return "escreva uma mensagem ou adicione um anexo para enviar"
    }
}

extension ComposerToolbar {
    func spokenSendHintReady() -> String {
        isExecuting
            ? "envia esta mensagem na fila do próximo turno"
            : "envia mensagem e anexos ao Atlas"
    }
}
