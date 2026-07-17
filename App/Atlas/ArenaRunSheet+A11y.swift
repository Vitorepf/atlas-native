import Foundation
import AtlasCore

// Spoken labels — peel de ArenaRunSheet (CICLO C residual honesty).
// Sheet/close → ArenaRunSheet+A11ySheet.swift

extension ArenaRunSheet {
    func spokenSubmitLabel(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return "rodar medição"
        }
        if enginesEmpty {
            return "rodar medição indisponível, nenhum motor publicado"
        }
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        if missing.isEmpty { return "rodar medição indisponível" }
        return "rodar medição indisponível, falta \(missing.joined(separator: ", "))"
    }

    func spokenSubmitHint(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return "envia medição governada ao servidor"
        }
        if enginesEmpty {
            return "aguarde o servidor publicar pelo menos um motor"
        }
        return "preencha ator, motivo, suites, motor e braços"
    }

    func spokenEmptyEngines() -> String {
        "nenhum motor publicado pelo servidor, rodar medição indisponível"
    }

    func spokenEmptySuites() -> String {
        "nenhuma suite com adapter instalado, rodar medição indisponível"
    }

    func spokenReceiptLabel(_ receipt: AtlasArenaStartReceipt) -> String {
        var parts = ["recibo \(receipt.receiptHash)"]
        parts.append(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
        if receipt.workerImplemented == false {
            parts.append("worker de medição ainda não implementado")
        }
        return parts.joined(separator: ", ")
    }

    func spokenActorHint() -> String {
        "nome de quem autoriza a medição"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }

    func spokenErrorLabel(_ message: String) -> String {
        "erro: \(message)"
    }
}
