import AtlasCore
import Foundation
import SwiftUI

// Cycle 026 fuse → ArenaRunSheet+A11y.swift

extension ArenaRunSheet {
    func spokenSubmitLabel(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return spokenSubmitValid()
        }
        if enginesEmpty {
            return spokenSubmitEnginesEmpty()
        }
        return spokenSubmitMissing(input: input)
    }
}

extension ArenaRunSheet {
    func spokenEmptyEngines() -> String {
        "nenhum motor publicado pelo servidor, rodar medição indisponível"
    }

    func spokenEmptySuites() -> String {
        "nenhuma suite com adapter instalado, rodar medição indisponível"
    }
}

extension ArenaRunSheet {
    func spokenEnginesCount() -> String {
        if engines.isEmpty {
            return "nenhum motor publicado"
        }
        return "\(engines.count) motor\(engines.count == 1 ? "" : "es")"
    }
}

extension ArenaRunSheet {
    func spokenErrorLabel(_ message: String) -> String {
        "erro: \(message)"
    }
}

extension ArenaRunSheet {
    func spokenSubmitHint(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return "envia medição governada ao servidor"
        }
        if enginesEmpty {
            return "aguarde o servidor publicar pelo menos um motor"
        }
        return "preencha ator, motivo, suites, motor e braços"
    }
}

extension ArenaRunSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza a medição"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissingOperator(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        return missing
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissingSuite(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        return missing
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissing(input: AtlasArenaStartInput) -> String {
        let missing = spokenSubmitMissingOperator(input: input)
            + spokenSubmitMissingSuite(input: input)
        if missing.isEmpty { return "rodar medição indisponível" }
        return "rodar medição indisponível, falta \(missing.joined(separator: ", "))"
    }
}

extension ArenaRunSheet {
    func spokenReceiptLabel(_ receipt: AtlasArenaStartReceipt) -> String {
        var parts = ["recibo \(receipt.receiptHash)"]
        parts.append(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
        if receipt.workerImplemented == false {
            parts.append("worker de medição ainda não implementado")
        }
        return parts.joined(separator: ", ")
    }
}

extension ArenaRunSheet {
    func spokenCloseLabel() -> String { "fechar folha de medição" }

    func spokenCloseHint() -> String { "volta para a Arena sem enviar" }
}

extension ArenaRunSheet {
    func spokenSheetHint() -> String {
        "escolhe suites, motor e braços; ator e motivo auditáveis são obrigatórios"
    }
}

extension ArenaRunSheet {
    func spokenSheetLabel() -> String {
        var parts = ["rodar medição Arena"]
        parts.append(spokenEnginesCount())
        parts.append(spokenSuitesCount())
        return parts.joined(separator: ", ")
    }
}

extension ArenaRunSheet {
    func spokenSubmitEnginesEmpty() -> String {
        "rodar medição indisponível, nenhum motor publicado"
    }
}

extension ArenaRunSheet {
    func spokenSubmitValid() -> String {
        "rodar medição"
    }
}

extension ArenaRunSheet {
    func spokenSuitesCount() -> String {
        let suites = installedSuites.count
        if suites == 0 {
            return "nenhuma suite com adapter"
        }
        return "\(suites) suite\(suites == 1 ? "" : "s") instalada\(suites == 1 ? "" : "s")"
    }
}

extension ArenaRunSheet {
    func runSheetA11y<V: View>(_ content: V) -> some View {
        content
            .onAppear { seedDefaultsIfNeeded() }
            .accessibilityIdentifier(A11yID.arenaRunSheet)
            .accessibilityLabel(spokenSheetLabel())
            .accessibilityHint(spokenSheetHint())
    }
}
