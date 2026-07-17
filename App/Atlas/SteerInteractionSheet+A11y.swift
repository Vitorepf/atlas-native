import Foundation
import AtlasCore

// Spoken labels — peel de SteerInteractionSheet (CICLO C residual honesty).
// Recibo só de model.lastSteerReceipt; silêncio total sem recibo correspondente.

extension SteerInteractionSheet {
    func spokenScopeLabel(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "escopo passo atual"
        case .replan: return "escopo replanejamento"
        }
    }

    func spokenReceiptLabel(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "último recibo, instrução enfileirada para o próximo checkpoint seguro"
        }
        let reason = receipt.reason?.rawValue ?? "motivo_indisponivel"
        return "último recibo, steering rejeitado, motivo \(reason)"
    }

    func spokenSubmitLabel(canSubmit: Bool) -> String {
        canSubmit ? "enviar instrução de redirecionamento" : "enviar indisponível, instrução vazia"
    }

    func spokenSubmitHint(canSubmit: Bool) -> String {
        canSubmit
            ? "envia a instrução ao Atlas no escopo selecionado"
            : "escreva o que muda a partir daqui"
    }

    func spokenSheetHint() -> String {
        "instrução entra no próximo checkpoint seguro; o Atlas pode recusar"
    }
}
