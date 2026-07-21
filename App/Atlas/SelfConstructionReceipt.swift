import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

struct SelfConstructionReceipt: Identifiable {
    let cycle: AtlasAutonomosCycle
    let finding: AtlasAutonomosFinding?

    var id: String { cycle.id }

    var hasMergeProof: Bool {
        cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
    }
}

extension SelfConstructionReceipt {
    var title: String {
        if let findingTitle = finding?.title.nonEmpty { return findingTitle }
        if hasMergeProof { return "Entrega comprovada no ledger" }
        return "Ciclo registrado sem merge neste recorte"
    }

    var ruleLabel: String {
        if let ruleId = finding?.ruleId?.nonEmpty, let text = finding?.ruleText?.nonEmpty {
            return "\(ruleId) — \(text)"
        }
        if let ruleId = finding?.ruleId?.nonEmpty { return "\(ruleId) — regra publicada sem texto neste recorte." }
        return "Regra não publicada no recorte deste recibo."
    }
}

extension SelfConstructionReceipt {
    var proofLine: String {
        let integrity = cycle.loopReceiptIntegrity.nonEmpty ?? "integridade não publicada"
        var parts = ["integridade \(integrity)", "ciclo \(cycle.cycleIndex)"]
        if hasMergeProof, let hash = cycle.mergeHash.nonEmpty {
            parts.insert("merge \(String(hash.prefix(8)))", at: 1)
        } else {
            parts.append("merge não publicado")
        }
        return parts.joined(separator: " · ")
    }
}
