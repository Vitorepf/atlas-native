import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive mid-run steer face (WAVE-053).
enum ConversationSteerFace: Equatable {
    /// Form open, instruction empty.
    case composing
    /// Instruction ready to submit.
    case ready
    /// Last receipt for this trace accepted (queued next checkpoint).
    case accepted
    /// Last receipt for this trace rejected with public reason.
    case rejected

    var productWord: String {
        switch self {
        case .composing: return "composing"
        case .ready: return "ready"
        case .accepted: return "accepted"
        case .rejected: return "rejected"
        }
    }

    var kicker: String {
        switch self {
        case .composing: return "Redirecionar"
        case .ready: return "Pronto para enviar"
        case .accepted: return "Enfileirado"
        case .rejected: return "Recusado"
        }
    }

    var spokenFace: String {
        switch self {
        case .composing:
            return "redirecionar, instrução vazia"
        case .ready:
            return "pronto para enviar instrução de redirecionamento"
        case .accepted:
            return "instrução enfileirada para o próximo checkpoint seguro"
        case .rejected:
            return "steering recusado"
        }
    }
}

// MARK: - Judgment

/// Pure steer grammar — face · submit · scope · receipt · pack.
enum ConversationSteerJudgment {

    static func hasInstruction(_ instruction: String) -> Bool {
        !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func allowsSubmit(instruction: String) -> Bool {
        hasInstruction(instruction)
    }

    /// Receipt only when it belongs to this trace (never cross-thread lie).
    static func matchedReceipt(
        last: AtlasInteractionSteerResponse?,
        traceId: TraceID
    ) -> AtlasInteractionSteerResponse? {
        guard let last else { return nil }
        if let receiptTrace = last.traceId, receiptTrace != traceId.rawValue {
            return nil
        }
        return last
    }

    static func face(
        instruction: String,
        last: AtlasInteractionSteerResponse?,
        traceId: TraceID
    ) -> ConversationSteerFace {
        if let receipt = matchedReceipt(last: last, traceId: traceId) {
            return receipt.isAccepted ? .accepted : .rejected
        }
        return hasInstruction(instruction) ? .ready : .composing
    }

    // MARK: Scope product words (not wire raw)

    static func scopeProductWord(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "passo_atual"
        case .replan: return "replanejar"
        }
    }

    static func scopeLabel(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "passo atual"
        case .replan: return "replanejar"
        }
    }

    static func spokenScope(_ scope: AtlasInteractionSteerScope) -> String {
        "escopo \(scopeLabel(scope))"
    }

    // MARK: Receipt

    static func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "na fila do próximo checkpoint"
        }
        return "rejeitado · \(rejectionReasonLabel(receipt.reason))"
    }

    static func rejectionReasonLabel(
        _ reason: AtlasInteractionSteerRejectionReason?
    ) -> String {
        guard let reason else { return "motivo indisponível" }
        switch reason {
        case .instructionRequired: return "instrução obrigatória"
        case .invalidScope: return "escopo inválido"
        case .traceWithoutThread: return "execução sem thread"
        case .noActiveJob: return "sem job ativo"
        }
    }

    static func spokenReceipt(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "último recibo, instrução enfileirada para o próximo checkpoint seguro"
        }
        return "último recibo, steering rejeitado, \(rejectionReasonLabel(receipt.reason))"
    }

    // MARK: Sheet chrome

    static func spokenSheetTitle(traceId: TraceID) -> String {
        "redirecionar execução \(traceId.rawValue)"
    }

    // MARK: Submit a11y

    static func spokenSubmitLabel(allowsSubmit: Bool) -> String {
        allowsSubmit
            ? "enviar instrução de redirecionamento"
            : "enviar indisponível, instrução vazia"
    }

    static func spokenSubmitHint(allowsSubmit: Bool) -> String {
        allowsSubmit
            ? "envia a instrução ao Atlas no escopo selecionado"
            : "escreva o que muda a partir daqui"
    }

    // MARK: Pack

    static func packFacts(
        instruction: String,
        scope: AtlasInteractionSteerScope,
        last: AtlasInteractionSteerResponse?,
        traceId: TraceID
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(instruction: instruction, last: last, traceId: traceId)
        facts.append("steer_face: \(face.productWord)")
        facts.append("steer_scope: \(scopeProductWord(scope))")
        facts.append("steer_allows_submit: \(allowsSubmit(instruction: instruction))")
        if hasInstruction(instruction) {
            let trimmed = instruction.trimmingCharacters(in: .whitespacesAndNewlines)
            let snip = trimmed.count <= 80 ? trimmed : String(trimmed.prefix(79)) + "…"
            facts.append("steer_instruction_draft: \(snip)")
        } else {
            absences.append("instrução de steer vazia neste recorte")
        }
        if let receipt = matchedReceipt(last: last, traceId: traceId) {
            facts.append("steer_receipt: \(receipt.status.rawValue)")
            facts.append("steer_receipt_line: \(receiptLine(receipt))")
            if let reason = receipt.reason {
                facts.append("steer_reject_reason: \(reason.rawValue)")
            }
        } else {
            absences.append("nenhum recibo de steer para este trace")
        }
        return (facts, absences)
    }
}
