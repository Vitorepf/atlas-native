import Foundation
import AtlasCore

// Spoken labels — peel de SteerInteractionSheet (CICLO C residual honesty).
// Recibo só de model.lastSteerReceipt; silêncio total sem recibo correspondente.
// Submit → SteerInteractionSheet+A11ySubmit.swift

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
}
