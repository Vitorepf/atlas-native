import Foundation
import AtlasCore

// Receipt spoken — peel de SteerInteractionSheet+A11y.

extension SteerInteractionSheet {
    func spokenReceiptLabel(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "último recibo, instrução enfileirada para o próximo checkpoint seguro"
        }
        let reason = receipt.reason?.rawValue ?? "motivo_indisponivel"
        return "último recibo, steering rejeitado, motivo \(reason)"
    }
}
