import Foundation
import AtlasCore

// Spoken labels — one truth with visual copy (WAVE-004 fuse).

extension ArenaRunSheet {
    func spokenSheetLabel() -> String {
        var parts = ["rodar medição Arena"]
        parts.append(spokenEnginesCount())
        parts.append(spokenSuitesCount())
        return parts.joined(separator: ", ")
    }

    func spokenSheetHint() -> String {
        "escolhe suites, motor e braços; ator e motivo auditáveis são obrigatórios"
    }

    func spokenCloseLabel() -> String { "fechar folha de medição" }
    func spokenCloseHint() -> String { "volta para a Arena sem enviar" }

    func spokenEnginesCount() -> String {
        if engines.isEmpty { return "nenhum motor publicado" }
        return "\(engines.count) motor\(engines.count == 1 ? "" : "es")"
    }

    func spokenSuitesCount() -> String {
        let suites = installedSuites.count
        if suites == 0 { return "nenhuma suite com adapter" }
        return "\(suites) suite\(suites == 1 ? "" : "s") instalada\(suites == 1 ? "" : "s")"
    }

    func spokenEmptyEngines() -> String {
        "nenhum motor publicado pelo servidor, rodar medição indisponível"
    }

    func spokenEmptySuites() -> String {
        "nenhuma suite com adapter instalado, rodar medição indisponível"
    }

    func spokenErrorLabel(_ message: String) -> String {
        "erro: \(message)"
    }

    func spokenActorHint() -> String {
        "nome de quem autoriza a medição"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }

    func spokenSubmitLabel(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return "rodar medição"
        }
        if enginesEmpty {
            return "rodar medição indisponível, nenhum motor publicado"
        }
        return spokenSubmitMissing(input: input)
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

    func spokenSubmitMissing(input: AtlasArenaStartInput) -> String {
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        if missing.isEmpty { return "rodar medição indisponível" }
        return "rodar medição indisponível, falta \(missing.joined(separator: ", "))"
    }

    func spokenReceiptLabel(_ receipt: AtlasArenaStartReceipt) -> String {
        var parts = ["recibo \(receipt.receiptHash)"]
        parts.append(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
        if receipt.workerImplemented == false {
            // Aligned with visual `workerGapCopy` — WAVE-004 DoD #1.
            parts.append(Self.workerGapCopy)
        }
        return parts.joined(separator: ", ")
    }
}
