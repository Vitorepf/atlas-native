import Foundation
import AtlasCore

// MARK: - Mission transfer handoff (WAVE-035)

/// Pure judgment for Autônomos mission transfer — never invents target worker.
enum AutonomosTransferJudgment {

    static let productWord = "transfer"
    static let ctaTitle = "Transferir missão"
    static let spokenFace = "transferência de missão com recibo"

    static let reasonTitle = "Transferir missão"
    static let reasonExplainer =
        "Preserva a mesma missão (área + foco). O target começa desconhecido — a fila escolhe o worker; só o lock dele comprova claimed. Não inicia execução no destino sozinho."

    /// Transfer only when area is selected and registered for control writes.
    static func canTransfer(canControlSelectedArea: Bool) -> Bool {
        canControlSelectedArea
    }

    static func receiptLine(_ receipt: AtlasAutonomosTransferResponse?) -> String? {
        guard let receipt else { return nil }
        if receipt.isTargetClaimed {
            let host = receipt.handoff.target.host?.trimmingCharacters(in: .whitespacesAndNewlines)
            let hostBit = (host?.isEmpty == false) ? " · \(host!)" : ""
            return "Handoff claimed\(hostBit) · \(receipt.handoff.handoffId.prefix(8))"
        }
        if receipt.isAwaitingSourceRelease {
            return "Transfer pedido · aguardando liberação da origem · \(receipt.handoff.handoffId.prefix(8))"
        }
        let note = receipt.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !note.isEmpty {
            return "Transfer · \(receipt.status) · \(note)"
        }
        return "Transfer · \(receipt.status) · \(receipt.handoff.handoffId.prefix(8))"
    }

    static func packFacts(
        canTransfer: Bool,
        receipt: AtlasAutonomosTransferResponse?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("can_transfer: \(canTransfer ? "yes" : "no")")
        if let receipt {
            facts.append("handoff_status: \(receipt.status)")
            facts.append("handoff_id: \(receipt.handoff.handoffId)")
            facts.append("target_status: \(receipt.handoff.target.status)")
            if receipt.isTargetClaimed {
                facts.append("handoff_face: claimed")
            } else if receipt.isAwaitingSourceRelease {
                facts.append("handoff_face: awaiting_source_release")
            }
        } else if canTransfer {
            absences.append("nenhum handoff pedido neste recorte")
        } else {
            absences.append("transfer indisponível — área unbound/unregistered")
        }
        absences.append("casca não escolhe worker target — servidor/fila decide")
        return (facts, absences)
    }
}
