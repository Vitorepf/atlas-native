import SwiftUI
import AtlasCore

struct SelfConstructionReceipt: Identifiable {
    let cycle: AtlasAutonomosCycle
    let finding: AtlasAutonomosFinding?

    var id: String { cycle.id }
    var title: String { finding?.title.nonEmpty ?? "O Atlas melhorou o próprio app" }
    var ruleLabel: String {
        if let ruleId = finding?.ruleId?.nonEmpty, let text = finding?.ruleText?.nonEmpty {
            return "\(ruleId) — \(text)"
        }
        if let ruleId = finding?.ruleId?.nonEmpty { return "\(ruleId) — regra publicada sem texto neste recorte." }
        return "Regra não publicada no recorte deste recibo."
    }
    var proofLine: String {
        let merge = String(cycle.mergeHash.prefix(8))
        let integrity = cycle.loopReceiptIntegrity.nonEmpty ?? "integridade não publicada"
        return "integridade \(integrity) · merge \(merge) · ciclo \(cycle.cycleIndex)"
    }
}
